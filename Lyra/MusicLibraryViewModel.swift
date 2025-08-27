import Foundation
import AVFoundation
import MediaPlayer
import AppKit

class MusicLibraryViewModel: NSObject, ObservableObject {
    // MARK: - Canciones
    @Published var songs: [SongItem] = []
    @Published var searchText: String = ""
    @Published var currentSong: SongItem?

    // MARK: - Playlists
    @Published var playlists: [Playlist] = []
    @Published var selectedPlaylist: Playlist?

    // MARK: - Reproducción
    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var volume: Float = 1.0
    @Published var shuffle: Bool = false
    @Published var repeatMode: Bool = false

    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?

    private let saveFileName = "lyra_songs.json"
    private let savePlaylistsFile = "lyra_playlists.json"

    override init() {
        super.init()
        createLyraFolderIfNeeded()
        loadSongs()
        loadPlaylists()
        setupRemoteCommands()
    }

    // MARK: - Carpeta
    func lyraFolder() -> URL? {
        let fm = FileManager.default
        // Usar Documentos para evitar permisos de sandbox
        let folder = fm.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("LyraSongs")
        if !fm.fileExists(atPath: folder.path) {
            do {
                try fm.createDirectory(at: folder, withIntermediateDirectories: true)
            } catch {
                print("No se pudo crear LyraSongs: \(error.localizedDescription)")
                return nil
            }
        }
        return folder
    }

    private func createLyraFolderIfNeeded() { _ = lyraFolder() }

    // MARK: - Canciones y Playlists
    func addSongReturning(from url: URL) -> SongItem? {
        guard let folder = lyraFolder() else { return nil }
        let destURL = folder.appendingPathComponent(url.lastPathComponent)

        if !FileManager.default.fileExists(atPath: destURL.path) {
            do {
                try FileManager.default.copyItem(at: url, to: destURL)
            } catch {
                print("Error al copiar la canción: \(error.localizedDescription)")
                return nil
            }
        }

        let title = url.deletingPathExtension().lastPathComponent
        let song = SongItem(title: title, artist: "Desconocido", album: "Desconocido", fileURL: destURL)
        songs.append(song)
        saveSongs()
        return song
    }

    func deleteSong(_ song: SongItem) {
        songs.removeAll { $0.id == song.id }
        playlists = playlists.map { pl in
            var copy = pl
            copy.songs.removeAll { $0.id == song.id }
            return copy
        }
        saveSongs()
        savePlaylists()
        if currentSong?.id == song.id {
            stopPlayback()
        }
    }

    func addSong(_ song: SongItem, to playlist: Playlist) {
        guard let index = playlists.firstIndex(where: { $0.id == playlist.id }) else { return }
        if playlists[index].songs.contains(where: { $0.id == song.id }) { return }
        playlists[index].songs.append(song)
        savePlaylists()
    }

    func updateAlbumImage(for song: SongItem, with data: Data) {
        if let idx = songs.firstIndex(where: { $0.id == song.id }) {
            songs[idx].albumImageData = data
        }
        for pidx in playlists.indices {
            if let sidx = playlists[pidx].songs.firstIndex(where: { $0.id == song.id }) {
                playlists[pidx].songs[sidx].albumImageData = data
            }
        }
        saveSongs()
        savePlaylists()
        updateNowPlayingInfo()
    }

    func filteredSongs() -> [SongItem] {
        if searchText.isEmpty { return songs }
        return songs.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    func saveSongs() {
        guard let folder = lyraFolder() else { return }
        let url = folder.appendingPathComponent(saveFileName)
        try? JSONEncoder().encode(songs).write(to: url)
    }

    func loadSongs() {
        guard let folder = lyraFolder() else { return }
        let url = folder.appendingPathComponent(saveFileName)
        if let data = try? Data(contentsOf: url),
           let saved = try? JSONDecoder().decode([SongItem].self, from: data) {
            songs = saved
        }
    }

    func savePlaylists() {
        guard let folder = lyraFolder() else { return }
        let url = folder.appendingPathComponent(savePlaylistsFile)
        try? JSONEncoder().encode(playlists).write(to: url)
    }

    func loadPlaylists() {
        guard let folder = lyraFolder() else { return }
        let url = folder.appendingPathComponent(savePlaylistsFile)
        if let data = try? Data(contentsOf: url),
           let saved = try? JSONDecoder().decode([Playlist].self, from: data) {
            playlists = saved
        }
    }

    // MARK: - Reproducción
    func playSong(_ song: SongItem) {
        stopPlayback()
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: song.fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = volume
            audioPlayer?.play()
            currentSong = song
            duration = audioPlayer?.duration ?? 0
            currentTime = audioPlayer?.currentTime ?? 0
            isPlaying = true
            startTimer()
            updateNowPlayingInfo()
        } catch {
            print("Error al reproducir: \(error.localizedDescription)")
            currentSong = nil
            isPlaying = false
        }
    }

    func togglePlayback() {
        guard let player = audioPlayer else { return }
        if player.isPlaying { pausePlayback() } else { resumePlayback() }
    }

    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
        updateNowPlayingInfo()
    }

    func resumePlayback() {
        audioPlayer?.play()
        isPlaying = true
        startTimer()
        updateNowPlayingInfo()
    }

    func seek(to time: Double) {
        guard let player = audioPlayer else { return }
        let clamped = max(0, min(time, player.duration))
        player.currentTime = clamped
        currentTime = clamped
        updateNowPlayingInfo()
    }

    func seekForward(by seconds: Double) { seek(to: currentTime + seconds) }
    func seekBackward(by seconds: Double) { seek(to: currentTime - seconds) }

    func stopPlayback() {
        stopTimer()
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentTime = 0
        duration = 0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    func setVolume(_ value: Float) {
        volume = value
        audioPlayer?.volume = value
    }

    func toggleShuffle() { shuffle.toggle() }
    func toggleRepeat() { repeatMode.toggle() }

    // MARK: - Timer
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            self.currentTime = player.currentTime
            self.duration = player.duration
            self.updateNowPlayingInfo()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite && !seconds.isNaN else { return "0:00" }
        let total = Int(seconds.rounded())
        let m = total / 60
        let s = total % 60
        return String(format: "%d:%02d", m, s)
    }

    // MARK: - Control Center
    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.resumePlayback()
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pausePlayback()
            return .success
        }
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.togglePlayback()
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.seekForward(by: 15)
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.seekBackward(by: 15)
            return .success
        }
    }

    private func updateNowPlayingInfo() {
        guard let song = currentSong, let player = audioPlayer else { return }

        var info: [String: Any] = [
            MPMediaItemPropertyTitle: song.title,
            MPMediaItemPropertyArtist: song.artist,
            MPMediaItemPropertyAlbumTitle: song.album,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: player.currentTime,
            MPMediaItemPropertyPlaybackDuration: player.duration,
            MPNowPlayingInfoPropertyPlaybackRate: player.isPlaying ? 1.0 : 0.0
        ]

        if let image = song.albumImage ?? NSImage(systemSymbolName: "music.note", accessibilityDescription: nil) {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            info[MPMediaItemPropertyArtwork] = artwork
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}

// MARK: - AVAudioPlayerDelegate
extension MusicLibraryViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopTimer()
        if repeatMode, let current = currentSong {
            playSong(current)
        } else if let current = currentSong {
            // 🔹 Buscar lista de reproducción actual
            let currentList: [SongItem]
            if let pl = selectedPlaylist {
                currentList = pl.songs
            } else {
                currentList = songs
            }

            if let index = currentList.firstIndex(where: { $0.id == current.id }),
               index + 1 < currentList.count {
                // Reproducir la siguiente canción
                let nextSong = currentList[index + 1]
                playSong(nextSong)
            } else {
                // Se acabó la lista
                isPlaying = false
                currentTime = duration
                updateNowPlayingInfo()
            }
        }
    }
}
