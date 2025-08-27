import SwiftUI
import AppKit

struct BigPicturePlayerView: View {
    @ObservedObject var viewModel: MusicLibraryViewModel
    @Binding var isPresented: Bool
    @State private var isControlsVisible = true
    @State private var controlsTimer: Timer?
    @State private var progress: Double = 0
    @State private var isSeeking = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fondo con blur de la portada del álbum
                backgroundView

                // Contenido principal
                VStack(spacing: 20) {
                    headerView
                    albumArtAndInfoView(geometry: geometry)
                    Spacer()

                    if isControlsVisible {
                        playbackControlsView(geometry: geometry)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer()
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                toggleControlsVisibility()
            }
            .transition(.opacity.combined(with: .scale))
            .animation(.easeInOut(duration: 0.3), value: isPresented)
        }
        .onChange(of: viewModel.currentSong?.id) { _, _ in
            DispatchQueue.main.async {
                controlsTimer?.invalidate()
                controlsTimer = nil
                isControlsVisible = true
                resetControlsTimer()
            }
        }
        .onAppear {
            isControlsVisible = true
            resetControlsTimer()
            startProgressUpdates()
        }
        .onDisappear {
            controlsTimer?.invalidate()
            controlsTimer = nil
        }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    if value.translation.width < -50 {
                        viewModel.nextSong()
                    } else if value.translation.width > 50 {
                        viewModel.previousSong()
                    }
                }
        )
        .frame(minWidth: 800, minHeight: 600)
    }

    // MARK: - Background
    private var backgroundView: some View {
        Group {
            if let currentSong = viewModel.currentSong, let image = currentSong.albumImage {
                GeometryReader { geo in
                    Image(nsImage: sanitized(image: image))
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .blur(radius: 20)
                        .overlay(Color.black.opacity(0.6))
                }
            } else {
                Color.black.ignoresSafeArea()
            }
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isPresented = false
                }
            }) {
                Image(systemName: "chevron.down.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }
            .buttonStyle(PlainButtonStyle())
            .onTapGesture { } // evitar propagación

            Spacer()

            Image(systemName: "chevron.down.circle.fill")
                .font(.system(size: 28))
                .opacity(0)
        }
        .padding(.horizontal, 30)
        .padding(.top, 20)
    }

    // MARK: - Album Art & Info
    private func albumArtAndInfoView(geometry: GeometryProxy) -> some View {
        Group {
            if let currentSong = viewModel.currentSong {
                VStack(spacing: 20) {
                    if let image = currentSong.albumImage {
                        Image(nsImage: sanitized(image: image))
                            .resizable()
                            .scaledToFit()
                            .frame(
                                maxWidth: min(geometry.size.width * 0.4, 400),
                                maxHeight: min(geometry.size.height * 0.4, 400)
                            )
                            .cornerRadius(12)
                            .shadow(radius: 20)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(
                                width: min(geometry.size.width * 0.4, 400),
                                height: min(geometry.size.height * 0.4, 400)
                            )
                            .overlay(
                                Image(systemName: "music.note")
                                    .font(.system(size: 80))
                                    .foregroundColor(.white.opacity(0.5))
                            )
                    }

                    VStack(spacing: 8) {
                        Text(currentSong.title)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)

                        Text(currentSong.artist)
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)

                        Text(currentSong.album)
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.6))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .padding(.horizontal, 20)
                }
            } else {
                VStack(spacing: 20) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.3))
                        .frame(
                            width: min(geometry.size.width * 0.4, 400),
                            height: min(geometry.size.height * 0.4, 400)
                        )
                        .overlay(
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white.opacity(0.8))
                                Text("No hay canción")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            }
                        )

                    Text("Ninguna canción seleccionada")
                        .font(.title)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
    }

    // MARK: - Playback Controls
    private func playbackControlsView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 10) {
            // Barra de progreso
            CustomProgressBarView(
                progress: $progress,
                isSeeking: $isSeeking,
                onSeek: { newProgress in
                    viewModel.seek(to: newProgress * viewModel.duration)
                }
            )
            .frame(width: geometry.size.width * 0.6)
            .frame(height: 6)

            // Tiempos
            HStack {
                Text(viewModel.formatTime(viewModel.currentTime))
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Text(viewModel.formatTime(viewModel.duration))
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(width: geometry.size.width * 0.6)

            // Controles
            HStack(spacing: 30) {
                volumeControl
                navigationControls
                playbackModeControls
            }
        }
        .onTapGesture { } // prevenir propagación
    }

    private var volumeControl: some View {
        VStack {
            Image(systemName: viewModel.volume == 0 ? "speaker.slash" : "speaker.wave.2")
                .font(.system(size: 20))
                .foregroundColor(.white)

            Slider(value: Binding(
                get: { Double(viewModel.volume) },
                set: { newValue in
                    viewModel.setVolume(Float(newValue))
                }
            ), in: 0...1)
            .frame(width: 80)
            .accentColor(.white)
        }
    }

    private var navigationControls: some View {
        HStack(spacing: 20) {
            Button { viewModel.previousSong() } label: {
                Image(systemName: "backward.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }.buttonStyle(PlainButtonStyle())

            Button { viewModel.seekBackward(by: 15) } label: {
                Image(systemName: "gobackward.15")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }.buttonStyle(PlainButtonStyle())

            Button { viewModel.togglePlayback() } label: {
                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
            }.buttonStyle(PlainButtonStyle())

            Button { viewModel.seekForward(by: 15) } label: {
                Image(systemName: "goforward.15")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }.buttonStyle(PlainButtonStyle())

            Button { viewModel.nextSong() } label: {
                Image(systemName: "forward.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }.buttonStyle(PlainButtonStyle())
        }
    }

    private var playbackModeControls: some View {
        VStack(spacing: 10) {
            Button { viewModel.shuffle.toggle() } label: {
                Image(systemName: "shuffle")
                    .font(.system(size: 20))
                    .foregroundColor(viewModel.shuffle ? .blue : .white)
            }.buttonStyle(PlainButtonStyle())

            Button { viewModel.repeatMode.toggle() } label: {
                Image(systemName: viewModel.repeatMode ? "repeat.1" : "repeat")
                    .font(.system(size: 20))
                    .foregroundColor(viewModel.repeatMode ? .blue : .white)
            }.buttonStyle(PlainButtonStyle())
        }
    }

    // MARK: - Utils
    private func toggleControlsVisibility() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isControlsVisible.toggle()
        }
        if isControlsVisible { resetControlsTimer() }
        else { controlsTimer?.invalidate(); controlsTimer = nil }
    }

    private func resetControlsTimer() {
        controlsTimer?.invalidate()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.isControlsVisible = false
                }
            }
        }
    }

    private func startProgressUpdates() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            guard viewModel.currentSong != nil else { timer.invalidate(); return }
            if !isSeeking && viewModel.duration > 0 {
                DispatchQueue.main.async {
                    self.progress = self.viewModel.currentTime / self.viewModel.duration
                }
            }
        }
    }

    private func sanitized(image: NSImage) -> NSImage {
        guard let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff) else { return image }
        let sanitizedImage = NSImage(size: image.size)
        sanitizedImage.addRepresentation(bitmap)
        return sanitizedImage
    }
}

// MARK: - Custom Progress Bar
struct CustomProgressBarView: View {
    @Binding var progress: Double
    @Binding var isSeeking: Bool
    var onSeek: (Double) -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 6)
                    .cornerRadius(3)

                Rectangle()
                    .fill(Color.white)
                    .frame(width: geometry.size.width * CGFloat(progress), height: 6)
                    .cornerRadius(3)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isSeeking = true
                        let newProgress = min(max(0, Double(value.location.x / geometry.size.width)), 1)
                        progress = newProgress
                    }
                    .onEnded { value in
                        let newProgress = min(max(0, Double(value.location.x / geometry.size.width)), 1)
                        onSeek(newProgress)
                        isSeeking = false
                    }
            )
        }
        .frame(height: 6)
    }
}
