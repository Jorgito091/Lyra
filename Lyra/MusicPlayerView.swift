import SwiftUI

struct MusicPlayerView: View {
    @ObservedObject var viewModel: MusicLibraryViewModel
    @Binding var isExpanded: Bool
    @Binding var shuffle: Bool
    @Binding var repeatMode: Bool

    @State private var sliderValue: Double = 0
    @State private var isDraggingSlider: Bool = false

    var body: some View {
        VStack(spacing: 10) {
            if let current = viewModel.currentSong {
                HStack(spacing: 12) {
                    // Portada
                    if let image = current.albumImage {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: isExpanded ? 60 : 45, height: isExpanded ? 60 : 45)
                            .cornerRadius(6)
                            .shadow(radius: 3)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: isExpanded ? 60 : 45, height: isExpanded ? 60 : 45)
                            .cornerRadius(6)
                            .overlay(
                                Image(systemName: "music.note")
                                    .foregroundColor(.white.opacity(0.6))
                            )
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(current.title)
                            .foregroundColor(.white)
                            .font(.headline)
                            .lineLimit(1)
                        Text(current.artist)
                            .foregroundColor(.gray)
                            .font(.subheadline)
                            .lineLimit(1)

                        // Barra de progreso
                        if isExpanded {
                            VStack(spacing: 2) {
                                Slider(
                                    value: Binding(
                                        get: {
                                            isDraggingSlider ? sliderValue : viewModel.currentTime
                                        },
                                        set: { newValue in
                                            sliderValue = newValue
                                            isDraggingSlider = true
                                        }
                                    ),
                                    in: 0...viewModel.duration,
                                    onEditingChanged: { editing in
                                        if !editing {
                                            viewModel.seek(to: sliderValue)
                                            isDraggingSlider = false
                                        }
                                    }
                                )
                                .accentColor(.accentColor)
                                .onChange(of: viewModel.currentTime) { newVal in
                                    if !isDraggingSlider {
                                        sliderValue = newVal
                                    }
                                }

                                HStack {
                                    Text(viewModel.formatTime(isDraggingSlider ? sliderValue : viewModel.currentTime))
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text(viewModel.formatTime(viewModel.duration))
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }

                    Spacer()

                    HStack(spacing: 18) {
                        Button { viewModel.toggleShuffle() } label: {
                            Image(systemName: "shuffle")
                                .foregroundColor(shuffle ? .accentColor : .gray)
                        }
                        .buttonStyle(PlainButtonStyle())

                        Button { viewModel.seekBackward(by: 15) } label: {
                            Image(systemName: "gobackward.15")
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())

                        Button { viewModel.togglePlayback() } label: {
                            Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(PlainButtonStyle())

                        Button { viewModel.seekForward(by: 15) } label: {
                            Image(systemName: "goforward.15")
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())

                        Button { viewModel.toggleRepeat() } label: {
                            Image(systemName: repeatMode ? "repeat.circle.fill" : "repeat")
                                .foregroundColor(repeatMode ? .accentColor : .gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)

                if isExpanded {
                    HStack {
                        Image(systemName: "speaker.fill").foregroundColor(.gray)
                        Slider(value: Binding(
                            get: { Double(viewModel.volume) },
                            set: { viewModel.setVolume(Float($0)) }
                        ), in: 0...1)
                        Image(systemName: "speaker.wave.3.fill").foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                }

                // Ecualizador y visualización de onda
                if isExpanded {
                    Group {
                        Text("Ecualizador")
                            .font(.caption)
                            .foregroundColor(.gray)
                        HStack {
                            ForEach(0..<viewModel.playerEngine.eqGains.count, id: \.self) { idx in
                                VStack {
                                    Slider(value: Binding(
                                        get: { viewModel.playerEngine.eqGains[idx] },
                                        set: { newVal in viewModel.playerEngine.setEQGain(band: idx, gain: newVal) }
                                    ), in: -24...24)
                                    Text(bandLabel(idx))
                                        .font(.caption2)
                                }
                            }
                        }
                        .padding(.horizontal)

                        Text("Visualización de onda")
                            .font(.caption)
                            .foregroundColor(.gray)
                        WaveformView(waveform: viewModel.playerEngine.waveform)
                            .frame(height: 40)
                            .padding(.horizontal)
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .background(BlurBackground())
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding(.horizontal)
    }

    func bandLabel(_ idx: Int) -> String {
        switch idx {
            case 0: return "Bajos"
            case 1: return "Medios"
            case 2: return "Agudos"
            default: return "Banda \(idx+1)"
        }
    }
}

// Fondo tipo blur
struct BlurBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .ultraDark
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
