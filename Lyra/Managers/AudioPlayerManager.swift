//
//  AudioPlayerManager.swift
//  Lyra
//
//  Manages audio playback with background support
//

import Foundation
import AVFoundation
import MediaPlayer

class AudioPlayerManager: NSObject, ObservableObject {
    static let shared = AudioPlayerManager()
    
    @Published var currentSong: Song?
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var playbackQueue: [Song] = []
    @Published var currentIndex: Int = 0
    
    private var player: AVAudioPlayer?
    private var timer: Timer?
    
    override private init() {
        super.init()
        setupAudioSession()
        setupRemoteCommands()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.playNext()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.playPrevious()
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self,
                  let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            self.seek(to: event.positionTime)
            return .success
        }
    }
    
    func playSong(_ song: Song, from queue: [Song] = []) {
        do {
            player?.stop()
            player = try AVAudioPlayer(contentsOf: song.fileURL)
            player?.delegate = self
            player?.prepareToPlay()
            
            currentSong = song
            duration = player?.duration ?? 0
            
            if !queue.isEmpty {
                playbackQueue = queue
                if let index = queue.firstIndex(where: { $0.id == song.id }) {
                    currentIndex = index
                }
            }
            
            play()
            updateNowPlayingInfo()
        } catch {
            print("Failed to play song: \(error)")
        }
    }
    
    func play() {
        player?.play()
        isPlaying = true
        startTimer()
        updateNowPlayingInfo()
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
        stopTimer()
        updateNowPlayingInfo()
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func seek(to time: TimeInterval) {
        player?.currentTime = time
        currentTime = time
        updateNowPlayingInfo()
    }
    
    func playNext() {
        guard !playbackQueue.isEmpty else { return }
        currentIndex = (currentIndex + 1) % playbackQueue.count
        playSong(playbackQueue[currentIndex], from: playbackQueue)
    }
    
    func playPrevious() {
        guard !playbackQueue.isEmpty else { return }
        if currentTime > 3 {
            seek(to: 0)
        } else {
            currentIndex = (currentIndex - 1 + playbackQueue.count) % playbackQueue.count
            playSong(playbackQueue[currentIndex], from: playbackQueue)
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.player else { return }
            self.currentTime = player.currentTime
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateNowPlayingInfo() {
        guard let song = currentSong else { return }
        
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = song.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = song.artist
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = song.album
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        if let coverImage = song.coverImage {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: coverImage.size) { _ in
                return coverImage
            }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func stop() {
        player?.stop()
        player = nil
        currentSong = nil
        isPlaying = false
        currentTime = 0
        duration = 0
        stopTimer()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
}

extension AudioPlayerManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            playNext()
        }
    }
}
