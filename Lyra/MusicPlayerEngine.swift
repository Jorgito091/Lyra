import Foundation
import AVFoundation
import Combine

class MusicPlayerEngine: ObservableObject {
    let engine = AVAudioEngine()
    var player = AVAudioPlayerNode()
    let eq: AVAudioUnitEQ
    private var audioFile: AVAudioFile?
    private var tapInstalled = false

    @Published var waveform: [Float] = Array(repeating: 0, count: 100)
    @Published var eqGains: [Float]
    @Published var isPlaying: Bool = false
    @Published var duration: Double = 0
    @Published var currentTime: Double = 0

    private var timer: Timer?
    private var seekBaseTime: Double = 0

    /// Callback para cuando termina la canción
    var onSongEnd: (() -> Void)? = nil

    init(numberOfBands: Int = 3) {
        self.eq = AVAudioUnitEQ(numberOfBands: numberOfBands)
        self.eqGains = Array(repeating: 0, count: numberOfBands)
        let bandsFreq: [Float] = [100, 1000, 10000]
        for i in 0..<numberOfBands {
            eq.bands[i].filterType = .parametric
            eq.bands[i].frequency = bandsFreq[i]
            eq.bands[i].bandwidth = 1.0
            eq.bands[i].gain = 0
            eq.bands[i].bypass = false
        }
        engine.attach(player)
        engine.attach(eq)
        engine.connect(player, to: eq, format: nil)
        engine.connect(eq, to: engine.mainMixerNode, format: nil)
        try? engine.start()
    }

    func load(url: URL) throws {
        stop()
        audioFile = try AVAudioFile(forReading: url)
        guard let file = audioFile else { return }
        player.stop()
        let sampleRate = file.processingFormat.sampleRate
        let frameCount = AVAudioFrameCount(file.length)
        player.scheduleSegment(file, startingFrame: 0, frameCount: frameCount, at: nil, completionHandler: nil)
        duration = Double(file.length) / sampleRate
        currentTime = 0
        seekBaseTime = 0
        installTapIfNeeded()
    }

    func play() {
        if !player.isPlaying {
            player.play()
            isPlaying = true
            startTimer()
        }
    }

    func pause() {
        player.pause()
        isPlaying = false
        stopTimer()
    }

    func stop() {
        player.stop()
        isPlaying = false
        stopTimer()
        currentTime = 0
        seekBaseTime = 0
    }

    func seek(to time: Double) {
        guard let file = audioFile else { return }
        let sampleRate = file.processingFormat.sampleRate
        let lengthSeconds = Double(file.length) / sampleRate
        let nearEndMargin = 0.001

        print("SEEK REQUESTED: \(time) / duration: \(lengthSeconds)")

        if time >= lengthSeconds - nearEndMargin {
            print("Seek beyond end, triggering onSongEnd.")
            stop()
            DispatchQueue.main.async { [weak self] in
                self?.onSongEnd?()
            }
            return
        }

        // Reinicia el nodo: detach/attach/reconnect para limpiar buffers previos
        engine.detach(player)
        player = AVAudioPlayerNode()
        engine.attach(player)
        engine.connect(player, to: eq, format: file.processingFormat)
        engine.connect(eq, to: engine.mainMixerNode, format: file.processingFormat)

        let clampedTime = max(0, min(time, lengthSeconds - nearEndMargin))
        let startingFrame = AVAudioFramePosition(clampedTime * sampleRate)
        let remainingFrames = AVAudioFrameCount(file.length - startingFrame)
        print("Seek to \(clampedTime) (\(startingFrame) frames), remainingFrames: \(remainingFrames)")

        let wasPlaying = isPlaying

        player.stop()
        player.scheduleSegment(file, startingFrame: startingFrame, frameCount: remainingFrames, at: nil, completionHandler: nil)
        seekBaseTime = clampedTime
        currentTime = clampedTime

        if wasPlaying {
            player.play()
        }
        installTapIfNeeded()
    }

    func seekForward(by seconds: Double) {
        seek(to: currentTime + seconds)
    }

    func seekBackward(by seconds: Double) {
        seek(to: max(0, currentTime - seconds))
    }

    func setEQGain(band: Int, gain: Float) {
        guard band >= 0 && band < eq.bands.count else { return }
        eq.bands[band].gain = gain
        eqGains[band] = gain
    }

    private func installTapIfNeeded() {
        guard !tapInstalled else { return }
        let bus = 0
        engine.mainMixerNode.installTap(onBus: bus, bufferSize: 512, format: engine.mainMixerNode.outputFormat(forBus: bus)) { [weak self] (buffer, _) in
            guard let self = self else { return }
            let frameCount = Int(buffer.frameLength)
            guard let channelData = buffer.floatChannelData?[0] else { return }
            let samples = Array(UnsafeBufferPointer(start: channelData, count: frameCount))
            let downSampled = self.downSample(samples: samples, to: 100)
            DispatchQueue.main.async {
                self.waveform = downSampled
            }
        }
        tapInstalled = true
    }

    private func downSample(samples: [Float], to count: Int) -> [Float] {
        guard samples.count > count else { return samples }
        let step = samples.count / count
        return Swift.stride(from: 0, to: samples.count, by: step).map { i in
            let subArray = samples[i..<min(i+step, samples.count)]
            return subArray.max(by: { abs($0) < abs($1) }) ?? 0
        }
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self = self,
                  let nodeTime = self.player.lastRenderTime,
                  let playerTime = self.player.playerTime(forNodeTime: nodeTime),
                  let file = self.audioFile else { return }
            let seconds = Double(playerTime.sampleTime) / playerTime.sampleRate
            let realTime = self.seekBaseTime + seconds
            DispatchQueue.main.async {
                self.currentTime = min(realTime, self.duration)
                // Nueva: detección por timer del final de canción
                if self.isPlaying, self.currentTime >= self.duration - 0.05 {
                    self.stop()
                    self.onSongEnd?()
                }
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
