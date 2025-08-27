import SwiftUI
import AppKit

struct PlaylistSidebarView: View {
    @Binding var playlists: [Playlist]
    @Binding var selectedPlaylist: Playlist?
    var onCreatePlaylist: (() -> Void)? = nil
    var viewModel: MusicLibraryViewModel? // Para poder añadir canciones al drop

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Playlists")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                if let onCreate = onCreatePlaylist {
                    Button(action: onCreate) {
                        Image(systemName: "plus")
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)

            ScrollView {
                VStack(spacing: 6) {
                    ForEach(playlists) { playlist in
                        HStack {
                            if let data = playlist.imageData, let nsImage = NSImage(data: data) {
                                Image(nsImage: nsImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .cornerRadius(4)
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 30, height: 30)
                                    .cornerRadius(4)
                            }
                            Text(playlist.name)
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedPlaylist?.id == playlist.id ? Color.accentColor.opacity(0.3) : Color.clear)
                        )
                        .onTapGesture {
                            selectedPlaylist = playlist
                        }
                        // 🔹 Drop de canción
                        .onDrop(of: ["public.text"], isTargeted: nil) { providers in
                            guard let provider = providers.first else { return false }
                            provider.loadItem(forTypeIdentifier: "public.text", options: nil) { item, _ in
                                if let data = item as? Data,
                                   let idString = String(data: data, encoding: .utf8),
                                   let uuid = UUID(uuidString: idString),
                                   let song = viewModel?.songs.first(where: { $0.id == uuid }) {
                                    DispatchQueue.main.async {
                                        viewModel?.addSong(song, to: playlist)
                                    }
                                }
                            }
                            return true
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom)
        .background(Color.black.opacity(0.85))
    }
}
