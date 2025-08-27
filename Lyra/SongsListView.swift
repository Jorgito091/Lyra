import SwiftUI
import AppKit

struct SongsListView: View {
    let songs: [SongItem]
    let currentSong: SongItem?
    let isPlaying: Bool
    let playlists: [Playlist]

    let playAction: (SongItem) -> Void
    let onDelete: (SongItem) -> Void
    let onAddToPlaylist: (SongItem, Playlist) -> Void
    let onDoubleClick: (SongItem) -> Void
    let onEditAlbumArt: (SongItem) -> Void
    
    @State private var isDropTargeted = false

    var body: some View {
        List {
            if songs.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No hay canciones en tu biblioteca")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Arrastra archivos de audio aquí o haz clic en el botón + para añadir canciones")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                ForEach(songs) { song in
                    SongRowView(
                        song: song,
                        isPlaying: currentSong?.id == song.id && isPlaying,
                        playAction: { playAction(song) },
                        onEditAlbumArt: { onEditAlbumArt(song) }
                    )
                    .contentShape(Rectangle())
                    .onTapGesture(count: 2) { onDoubleClick(song) }
                    .contextMenu {
                        Button("Reproducir") { playAction(song) }
                        Button(role: .destructive) { onDelete(song) } label: { Text("Eliminar") }

                        Divider()
                        Menu("Añadir a playlist") {
                            if playlists.isEmpty {
                                Text("No hay playlists").foregroundColor(.secondary)
                            } else {
                                ForEach(playlists) { pl in
                                    Button(pl.name) { onAddToPlaylist(song, pl) }
                                }
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isDropTargeted ? Color.accentColor : Color.clear, lineWidth: 3)
                .background(isDropTargeted ? Color.accentColor.opacity(0.1) : Color.clear)
        )
        .animation(.easeInOut(duration: 0.2), value: isDropTargeted)
    }
}
