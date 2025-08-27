import SwiftUI

struct ImportSongsDialog: View {
    let urls: [URL]
    let viewModel: MusicLibraryViewModel
    let onDismiss: () -> Void
    
    @State private var importOptions: [URL: Bool] = [:]
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Importar Canciones")
                .font(.headline)
                .padding(.top)
            
            Text("Selecciona las canciones que deseas importar a Lyra:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(urls, id: \.self) { url in
                        HStack {
                            Image(systemName: "music.note")
                                .foregroundColor(.accentColor)
                                .frame(width: 20)
                            
                            Toggle(isOn: Binding(
                                get: { importOptions[url] ?? true },
                                set: { importOptions[url] = $0 }
                            )) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(url.lastPathComponent)
                                        .font(.system(size: 13, weight: .medium))
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                    Text(url.deletingLastPathComponent().path)
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                }
                            }
                            .toggleStyle(CheckboxToggleStyle())
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
                .padding(4)
            }
            .frame(maxHeight: 300)
            
            HStack {
                Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                    onDismiss()
                }
                
                Spacer()
                
                Button("Importar Selección") {
                    importSelectedSongs()
                    presentationMode.wrappedValue.dismiss()
                    onDismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(importOptions.values.filter { $0 }.isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(width: 500, height: 400)
        .onAppear {
            for url in urls {
                importOptions[url] = true
            }
        }
    }
    
    private func importSelectedSongs() {
        for url in urls where importOptions[url] == true {
            if let song = viewModel.addSongReturning(from: url) {
                if let selectedPlaylist = viewModel.selectedPlaylist {
                    viewModel.addSong(song, to: selectedPlaylist)
                }
            }
        }
        
        viewModel.saveSongs()
        viewModel.savePlaylists()
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? .accentColor : .secondary)
                .onTapGesture { configuration.isOn.toggle() }
        }
    }
}
