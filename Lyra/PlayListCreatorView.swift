import SwiftUI
import AppKit

struct PlaylistCreatorView: View {
    @Binding var playlists: [Playlist]
    @State private var newPlaylistName: String = ""
    @State private var newPlaylistImageData: Data? = nil
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            Text("Crear nueva Playlist")
                .font(.title2)
                .bold()

            TextField("Nombre de la playlist", text: $newPlaylistName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            VStack(spacing: 8) {
                if let imageData = newPlaylistImageData,
                   let nsImage = NSImage(data: imageData) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 120)
                        .cornerRadius(12)
                        .overlay(Text("Sin imagen").foregroundColor(.white.opacity(0.7)))
                }

                Button("Seleccionar Imagen") { selectImage() }
            }

            Button(action: createPlaylist) {
                Text("Crear Playlist")
                    .frame(maxWidth: .infinity)
            }
            .keyboardShortcut(.defaultAction)
            .disabled(newPlaylistName.trimmingCharacters(in: .whitespaces).isEmpty)
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)

            Spacer()
        }
        .padding()
        .frame(width: 400, height: 400)
        .background(Color.black.opacity(0.9))
        .cornerRadius(14)
        .foregroundColor(.white)
    }

    private func selectImage() {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["png", "jpg", "jpeg"]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        if panel.runModal() == .OK, let url = panel.url {
            if let data = try? Data(contentsOf: url) {
                self.newPlaylistImageData = data
            }
        }
    }

    private func createPlaylist() {
        let trimmedName = newPlaylistName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let playlist = Playlist(name: trimmedName, imageData: newPlaylistImageData, songs: [])
        playlists.append(playlist)
        presentationMode.wrappedValue.dismiss()
    }
}

