import SwiftUI
import AppKit

struct AddSongView: View {
    @Environment(\.dismiss) var dismiss
    var onSave: (SongItem) -> Void
    var onCancel: () -> Void
    var droppedURLs: [URL] = []
    
    @State private var title: String = ""
    @State private var artist: String = ""
    @State private var album: String = ""
    @State private var fileURL: URL?
    @State private var albumImage: NSImage?
    @State private var currentDroppedIndex: Int = 0
    
    @State private var showFileImporter = false
    @State private var showImagePicker = false
    
    // Inicializador correcto
    init(onSave: @escaping (SongItem) -> Void, onCancel: @escaping () -> Void, droppedURLs: [URL] = []) {
        self.onSave = onSave
        self.onCancel = onCancel
        self.droppedURLs = droppedURLs
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if !droppedURLs.isEmpty {
                // Mostrar indicador de múltiples archivos
                HStack {
                    Text("Archivo \(currentDroppedIndex + 1) de \(droppedURLs.count)")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                    
                    Spacer()
                    
                    Button(action: showPreviousFile) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title2)
                    }
                    .disabled(currentDroppedIndex <= 0)
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: showNextFile) {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.title2)
                    }
                    .disabled(currentDroppedIndex >= droppedURLs.count - 1)
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            
            Text("Agregar Canción")
                .font(.title2)
                .fontWeight(.bold)
            
            // Mostrar información del archivo actual
            if let currentFileURL = fileURL {
                VStack(spacing: 8) {
                    Text("Archivo seleccionado:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(currentFileURL.lastPathComponent)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .padding(.bottom, 8)
            }
            
            VStack(spacing: 12) {
                TextField("Título", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Artista", text: $artist)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Álbum", text: $album)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(spacing: 12) {
                // Solo mostrar botón de seleccionar archivo si no hay URLs arrastrados
                if droppedURLs.isEmpty {
                    HStack {
                        if let fileURL = fileURL {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Archivo:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(fileURL.lastPathComponent)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                        } else {
                            Button("Seleccionar Archivo de Audio") {
                                showFileImporter = true
                            }
                        }
                    }
                }
                
                HStack {
                    Button("Seleccionar Portada") {
                        showImagePicker = true
                    }
                    
                    if let albumImage = albumImage {
                        Image(nsImage: albumImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .shadow(radius: 2)
                    }
                }
            }
            
            Spacer()
            
            HStack {
                Button("Cancelar") {
                    onCancel()
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                if !droppedURLs.isEmpty && droppedURLs.count > 1 {
                    Button("Agregar Todos") {
                        addAllDroppedFiles()
                        dismiss()
                    }
                }
                
                Button("Guardar") {
                    saveCurrentSong()
                }
                .disabled(fileURL == nil)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 450, height: 500)
        .onAppear {
            if !droppedURLs.isEmpty {
                loadCurrentDroppedFile()
            }
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.audio]) { result in
            if case .success(let url) = result {
                fileURL = url
                autoFillMetadata(from: url)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView { image in
                self.albumImage = image
            }
        }
    }
    
    private func loadCurrentDroppedFile() {
        guard currentDroppedIndex < droppedURLs.count else { return }
        fileURL = droppedURLs[currentDroppedIndex]
        autoFillMetadata(from: droppedURLs[currentDroppedIndex])
    }
    
    private func autoFillMetadata(from url: URL) {
        let fileName = url.deletingPathExtension().lastPathComponent
        
        // Solo auto-completar si los campos están vacíos
        if title.isEmpty {
            // Patrones comunes: "Artista - Título" o "Título - Artista"
            if let range = fileName.range(of: " - ") {
                let artistPart = String(fileName[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
                let titlePart = String(fileName[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                
                if artist.isEmpty { artist = artistPart }
                if title.isEmpty { title = titlePart }
            } else {
                title = fileName
            }
        }
        
        if album.isEmpty {
            album = "Álbum Desconocido"
        }
        
        if artist.isEmpty {
            artist = "Artista Desconocido"
        }
    }
    
    private func showNextFile() {
        guard currentDroppedIndex < droppedURLs.count - 1 else { return }
        currentDroppedIndex += 1
        loadCurrentDroppedFile()
    }
    
    private func showPreviousFile() {
        guard currentDroppedIndex > 0 else { return }
        currentDroppedIndex -= 1
        loadCurrentDroppedFile()
    }
    
    private func saveCurrentSong() {
        guard let fileURL = fileURL else { return }
        let imageData = albumImage?.tiffRepresentation
        let newSong = SongItem(
            title: title.isEmpty ? fileURL.deletingPathExtension().lastPathComponent : title,
            artist: artist.isEmpty ? "Artista Desconocido" : artist,
            album: album.isEmpty ? "Álbum Desconocido" : album,
            fileURL: fileURL,
            albumImageData: imageData
        )
        onSave(newSong)
        
        if !droppedURLs.isEmpty {
            showNextFileOrDismiss()
        } else {
            dismiss()
        }
    }
    
    private func showNextFileOrDismiss() {
        if currentDroppedIndex < droppedURLs.count - 1 {
            showNextFile()
            // Resetear campos para el siguiente archivo
            title = ""
            artist = ""
            album = ""
            albumImage = nil
        } else {
            dismiss()
        }
    }
    
    private func addAllDroppedFiles() {
        for url in droppedURLs {
            let fileName = url.deletingPathExtension().lastPathComponent
            let imageData = albumImage?.tiffRepresentation
            
            let newSong = SongItem(
                title: fileName,
                artist: "Artista Desconocido",
                album: "Álbum Desconocido",
                fileURL: url,
                albumImageData: imageData
            )
            onSave(newSong)
        }
        dismiss()
    }
}
//AGREGADO EL URL DE YOUTUBE PARA MANEJAR LA FUNCIONALIDAD 