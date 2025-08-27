import SwiftUI
import AppKit
import UniformTypeIdentifiers

// Delegate personalizado para manejar el cierre de la ventana
class BigPictureWindowDelegate: NSObject, NSWindowDelegate {
    private let onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
        super.init()
    }
    
    func windowWillClose(_ notification: Notification) {
        onClose()
    }
}

struct MusicLibraryView: View {
    @StateObject private var viewModel = MusicLibraryViewModel()
    @State private var showingPlaylistCreator = false
    @State private var showingAddSong = false
    @State private var isPlayerExpanded: Bool = true
    @State private var shuffle: Bool = false
    @State private var repeatMode: Bool = false
    @State private var showingImportDialog = false
    @State private var droppedURLs: [URL] = []
    @State private var isDraggingOver = false
    @State private var showingBigPicture = false
    @State private var bigPictureTransition = false
    @State private var bigPictureWindow: NSWindow? // Para la ventana personalizada
    @State private var windowDelegate: BigPictureWindowDelegate? // Para retener el delegate

    var body: some View {
        ZStack {
            // Contenido principal
            HStack(spacing: 0) {
                // Sidebar de playlists
                PlaylistSidebarView(
                    playlists: $viewModel.playlists,
                    selectedPlaylist: $viewModel.selectedPlaylist,
                    onCreatePlaylist: { showingPlaylistCreator = true },
                    viewModel: viewModel
                )
                .frame(width: 220)

                Divider()

                VStack(spacing: 0) {
                    // Barra superior
                    HStack {
                        TextField("Buscar…", text: $viewModel.searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)

                        // Botón de pantalla completa
                        if viewModel.currentSong != nil {
                            Button(action: {
                                print("🎵 Botón pantalla completa presionado")
                                print("🎵 Current Song antes de abrir: \(viewModel.currentSong?.title ?? "nil")")
                                openBigPictureWindow()
                            }) {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                            }
                            .help("Modo pantalla completa")
                        }

                        Button(action: { showingAddSong = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                        }
                        .help("Añadir canción")
                        .padding(.trailing)
                    }
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(colors: [.black.opacity(0.9), .black], startPoint: .top, endPoint: .bottom)
                    )

                    Divider()

                    // Lista de canciones
                    SongsListView(
                        songs: currentSongs,
                        currentSong: viewModel.currentSong,
                        isPlaying: viewModel.isPlaying,
                        playlists: viewModel.playlists,
                        playAction: { song in
                            if viewModel.currentSong?.id == song.id {
                                viewModel.togglePlayback()
                            } else {
                                viewModel.playSong(song)
                            }
                        },
                        onDelete: { song in viewModel.deleteSong(song) },
                        onAddToPlaylist: { song, pl in viewModel.addSong(song, to: pl) },
                        onDoubleClick: { song in viewModel.playSong(song) },
                        onEditAlbumArt: { song in selectAlbumArt(for: song) }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    Divider()

                    // Mini reproductor
                    if viewModel.currentSong != nil {
                        MusicPlayerView(
                            viewModel: viewModel,
                            isExpanded: $isPlayerExpanded,
                            shuffle: $shuffle,
                            repeatMode: $repeatMode
                        )
                        .frame(height: isPlayerExpanded ? 140 : 80)
                        .transition(.move(edge: .bottom))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(NSColor.windowBackgroundColor))
            .opacity(bigPictureTransition ? 0 : 1)
            
            // Overlay de drag & drop
            if isDraggingOver {
                DropOverlayView()
                    .transition(.opacity)
            }
        }
        .sheet(isPresented: $showingPlaylistCreator) {
            PlaylistCreatorView(playlists: $viewModel.playlists)
        }
        .sheet(isPresented: $showingAddSong) {
            AddSongView(
                onSave: { newSong in
                    if let folder = viewModel.lyraFolder() {
                        let destURL = folder.appendingPathComponent(newSong.fileURL.lastPathComponent)
                        if !FileManager.default.fileExists(atPath: destURL.path) {
                            do {
                                try FileManager.default.copyItem(at: newSong.fileURL, to: destURL)
                            } catch {
                                print("Error al copiar la canción: \(error.localizedDescription)")
                                return
                            }
                        }
                        let songToAdd = SongItem(
                            title: newSong.title,
                            artist: newSong.artist,
                            album: newSong.album,
                            fileURL: destURL,
                            albumImageData: newSong.albumImageData
                        )
                        viewModel.songs.append(songToAdd)
                        if let selectedPL = viewModel.selectedPlaylist {
                            viewModel.addSong(songToAdd, to: selectedPL)
                        }
                        viewModel.saveSongs()
                        viewModel.savePlaylists()
                    }
                    droppedURLs.removeAll()
                },
                onCancel: {
                    droppedURLs.removeAll()
                },
                droppedURLs: droppedURLs
            )
        }
        .onDrop(of: [.fileURL], isTargeted: $isDraggingOver) { providers in
            handleDrop(providers: providers)
        }
        .background(
            DropDetectorView(isDraggingOver: $isDraggingOver)
                .frame(width: 0, height: 0)
        )
        .onAppear {
            DispatchQueue.main.async {
                if let window = NSApplication.shared.windows.first {
                    window.makeFirstResponder(window.contentView)
                }
            }
        }
        .onDisappear {
            // Cerrar la ventana de pantalla completa si está abierta
            bigPictureWindow?.close()
            bigPictureWindow = nil
            windowDelegate = nil
        }
    }

    // Canciones actuales según playlist
    private var currentSongs: [SongItem] {
        if let pl = viewModel.selectedPlaylist {
            return pl.songs
        } else {
            return viewModel.filteredSongs()
        }
    }

    // MARK: - Pantalla completa con ventana personalizada
    private func openBigPictureWindow() {
        // Cerrar ventana anterior si existe
        bigPictureWindow?.close()
        
        // Crear nueva ventana
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1200, height: 800),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Reproductor - Pantalla Completa"
        window.center()
        window.isReleasedWhenClosed = false
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        
        // Crear el contenido de la ventana
        let bigPictureView = BigPicturePlayerView(
            viewModel: viewModel,
            isPresented: Binding(
                get: { true },
                set: { _ in
                    // Cuando BigPicturePlayerView quiera cerrar la ventana
                    window.close()
                }
            )
        )
        
        window.contentView = NSHostingView(rootView: bigPictureView)
        
        // Configurar el delegate de la ventana para limpiar la referencia al cerrar
        let delegate = BigPictureWindowDelegate {
            DispatchQueue.main.async {
                self.bigPictureWindow = nil
                self.windowDelegate = nil
            }
        }
        window.delegate = delegate
        self.windowDelegate = delegate
        
        // Mostrar la ventana
        window.makeKeyAndOrderFront(nil)
        
        // Configurar el botón de cerrar
        if let closeButton = window.standardWindowButton(.closeButton) {
            closeButton.target = nil
            closeButton.action = nil
        }
        
        // Guardar referencia
        bigPictureWindow = window
        
        // Opcional: Hacer que la ventana entre en pantalla completa automáticamente
        // window.toggleFullScreen(nil)
    }

    // Seleccionar carátula desde la lista
    private func selectAlbumArt(for song: SongItem) {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["png", "jpg", "jpeg"]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        if panel.runModal() == .OK, let url = panel.url {
            if url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                
                if let data = try? Data(contentsOf: url) {
                    viewModel.updateAlbumImage(for: song, with: data)
                }
            } else {
                print("No se puede acceder a la imagen por permisos")
            }
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        isDraggingOver = false
        guard !providers.isEmpty else { return false }
        
        var loadedURLs: [URL] = []
        let group = DispatchGroup()
        
        for provider in providers {
            group.enter()
            
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (item, error) in
                defer { group.leave() }
                
                if let securityScopedURL = item as? URL {
                    if securityScopedURL.startAccessingSecurityScopedResource() {
                        defer { securityScopedURL.stopAccessingSecurityScopedResource() }
                        
                        if self.isAudioFile(securityScopedURL) {
                            if let localURL = self.copyToLyraFolder(securityScopedURL) {
                                DispatchQueue.main.async {
                                    loadedURLs.append(localURL)
                                }
                            }
                        }
                    }
                } else if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                    if self.isAudioFile(url) {
                        DispatchQueue.main.async {
                            loadedURLs.append(url)
                        }
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            if !loadedURLs.isEmpty {
                self.droppedURLs = loadedURLs
                self.showingAddSong = true
            }
        }
        
        return true
    }
    
    private func isAudioFile(_ url: URL) -> Bool {
        let pathExtension = url.pathExtension.lowercased()
        let audioExtensions = ["mp3", "m4a", "wav", "aiff", "aif", "flac", "alac", "aac"]
        return audioExtensions.contains(pathExtension)
    }
    
    private func copyToLyraFolder(_ sourceURL: URL) -> URL? {
        guard let destinationFolder = viewModel.lyraFolder() else { return nil }
        let destinationURL = destinationFolder.appendingPathComponent(sourceURL.lastPathComponent)
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            return destinationURL
        }
        do {
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            return destinationURL
        } catch {
            print("Error copiando archivo: \(error.localizedDescription)")
            return nil
        }
    }
}

struct MusicLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        MusicLibraryView()
            .frame(width: 1200, height: 800)
    }
}
