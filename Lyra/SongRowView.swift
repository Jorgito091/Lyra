import SwiftUI

struct SongRowView: View {
    let song: SongItem
    let isPlaying: Bool
    let playAction: () -> Void
    let onEditAlbumArt: (() -> Void)?

    var body: some View {
        HStack(spacing: 10) {
            if let albumImage = song.albumImage {
                Image(nsImage: albumImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .cornerRadius(4)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .cornerRadius(4)
            }

            VStack(alignment: .leading) {
                Text(song.title)
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(song.artist)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            if let onEdit = onEditAlbumArt {
                Button(action: onEdit) {
                    Image(systemName: "photo")
                }
                .buttonStyle(BorderlessButtonStyle())
            }

            Button(action: playAction) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(isPlaying ? Color.accentColor.opacity(0.2) : Color.clear)
        .cornerRadius(6)
    }
}
