import SwiftUI
import AppKit
import UniformTypeIdentifiers

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
            }
            
            // Manejador de teclado
            KeyboardEventHandler(viewModel: viewModel)
                .frame(width: 0, height: 0)
            
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
    }

    // Canciones actuales según playlist
    private var currentSongs: [SongItem] {
        if let pl = viewModel.selectedPlaylist {
            return pl.songs
        } else {
            return viewModel.filteredSongs()
        }
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
            
            // Método mejorado para manejar permisos de sandbox
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (item, error) in
                defer { group.leave() }
                
                if let securityScopedURL = item as? URL {
                    // Intentar acceso con seguridad de scope
                    if securityScopedURL.startAccessingSecurityScopedResource() {
                        defer { securityScopedURL.stopAccessingSecurityScopedResource() }
                        
                        if self.isAudioFile(securityScopedURL) {
                            // Copiar el archivo a la carpeta de Lyra
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
                // Usar AddSongView para los archivos arrastrados
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
        
        // Si ya existe, no copiar
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
    }
}
