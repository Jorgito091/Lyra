import SwiftUI

struct PlayerControlsView: View {
    @ObservedObject var viewModel: MusicLibraryViewModel

    var body: some View {
        VStack(spacing: 12) {
            if let current = viewModel.currentSong {
                HStack {
                    VStack(alignment: .leading) {
                        Text(current.title)
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text("\(current.artist) — \(current.album)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button {
                        viewModel.togglePlayback()
                    } label: {
                        Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.accentColor)
                    }
                }

                VStack {
                    Slider(
                        value: Binding(
                            get: { viewModel.currentTime },
                            set: { viewModel.seek(to: $0) }
                        ),
                        in: 0...(viewModel.duration > 0 ? viewModel.duration : 1)
                    )
                    .accentColor(.accentColor)

                    HStack {
                        Text(viewModel.formatTime(viewModel.currentTime))
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Text(viewModel.formatTime(viewModel.duration))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                HStack(spacing: 20) {
                    Button { viewModel.seekBackward(by: 15) } label: {
                        Image(systemName: "gobackward.15").font(.title2)
                    }
                    Spacer()
                    Button { viewModel.seekForward(by: 15) } label: {
                        Image(systemName: "goforward.15").font(.title2)
                    }
                    Spacer()
                    HStack {
                        Image(systemName: "speaker.fill").foregroundColor(.gray)
                        Slider(
                            value: Binding(
                                get: { viewModel.volume },
                                set: { viewModel.setVolume($0) }
                            ),
                            in: 0...1
                        )
                        .accentColor(.accentColor)
                        Image(systemName: "speaker.wave.3.fill").foregroundColor(.gray)
                    }
                    .frame(width: 150)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(colors: [Color.black.opacity(0.85), Color.black],
                           startPoint: .top, endPoint: .bottom)
                .cornerRadius(14)
        )
        .padding(.horizontal)
        .shadow(color: Color.black.opacity(0.5), radius: 6, x: 0, y: 3)
    }
}
