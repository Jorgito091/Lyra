import SwiftUI

struct PlaylistPickerSheet: View {
    let playlists: [Playlist]
    let song: SongItem
    let onPick: (Playlist) -> Void

    @Environment(\.presentationMode) private var presentation

    var body: some View {
        VStack(spacing: 12) {
            Text("Añadir a playlist")
                .font(.headline)

            if playlists.isEmpty {
                Text("No tienes playlists todavía.")
                    .foregroundColor(.secondary)
            } else {
                List(playlists) { pl in
                    HStack {
                        if let data = pl.imageData, let nsImage = NSImage(data: data) {
                            Image(nsImage: nsImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 28, height: 28)
                                .cornerRadius(6)
                        } else {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 28, height: 28)
                        }
                        Text(pl.name)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onPick(pl)
                        presentation.wrappedValue.dismiss()
                    }
                }
                .frame(minHeight: 180, maxHeight: 280)
            }

            HStack {
                Spacer()
                Button("Cerrar") { presentation.wrappedValue.dismiss() }
            }
        }
        .padding()
        .frame(width: 360)
    }
}
