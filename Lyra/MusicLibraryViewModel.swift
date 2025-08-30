import Foundation
import SwiftUI
import Combine
import AVFoundation
import MediaPlayer
import AppKit

@MainActor
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

    // Nuevo: Engine avanzado y visualización
    @Published var playerEngine = MusicPlayerEngine()
    private var engineCancellables: Set<AnyCancellable> = []

    private var timer: Timer?
    private var playbackQueue: [SongItem] = []

    private let saveFileName = "lyra_songs.json"
    private let savePlaylistsFile = "lyra_playlists.json"

    override init() {
        super.init()
        createLyraFolderIfNeeded()
        loadSongs()
        loadPlaylists()
        setupRemoteCommands()
        observeEngine()

        // Handler para el final de canción
        playerEngine.onSongEnd = { [weak self] in
            self?.handleSongEnded()
        }
    }

    func handleSongEnded() {
        if repeatMode {
            playerEngine.seek(to: 0)
            playerEngine.play()
        } else {
            nextSong()
        }
    }

    private func observeEngine() {
        playerEngine.$isPlaying
            .assign(to: &$isPlaying)
        playerEngine.$currentTime
            .assign(to: &$currentTime)
        playerEngine.$duration
            .assign(to: &$duration)
    }

    // MARK: - Carpeta
    func lyraFolder() -> URL? {
        let fm = FileManager.default
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

    // MARK: - Lista actual de reproducción
    func getCurrentPlaylist() -> [SongItem] {
        if let selectedPlaylist = selectedPlaylist {
            return selectedPlaylist.songs
        } else {
            return filteredSongs()
        }
    }

    // MARK: - Navegación de canciones
    func nextSong() {
        guard let current = currentSong else { return }

        let currentList = getCurrentPlaylist()
        guard !currentList.isEmpty else { return }

        if let index = currentList.firstIndex(where: { $0.id == current.id }) {
            if shuffle {
                var availableSongs = currentList.filter { $0.id != current.id }
                if availableSongs.isEmpty {
                    availableSongs = currentList
                }
                let nextSong = availableSongs.randomElement()!
                playSong(nextSong)
            } else {
                let nextIndex = (index + 1) % currentList.count
                let nextSong = currentList[nextIndex]
                playSong(nextSong)
            }
        }
    }

    func previousSong() {
        guard let current = currentSong else { return }

        let currentList = getCurrentPlaylist()
        guard !currentList.isEmpty else { return }

        if let index = currentList.firstIndex(where: { $0.id == current.id }) {
            if shuffle {
                var availableSongs = currentList.filter { $0.id != current.id }
                if availableSongs.isEmpty {
                    availableSongs = currentList
                }
                let previousSong = availableSongs.randomElement()!
                playSong(previousSong)
            } else {
                let previousIndex = index == 0 ? currentList.count - 1 : index - 1
                let previousSong = currentList[previousIndex]
                playSong(previousSong)
            }
        }
    }

    // MARK: - Reproducción con AVAudioEngine
    func playSong(_ song: SongItem) {
        print("🎵 Reproduciendo: \(song.title) - ID: \(song.id.uuidString.prefix(8))")
        stopPlayback()
        do {
            try playerEngine.load(url: song.fileURL)
            playerEngine.play()
            self.currentSong = song
            self.isPlaying = true
        } catch {
            print("❌ Error al reproducir: \(error.localizedDescription)")
            self.currentSong = nil
            self.isPlaying = false
        }
        updateNowPlayingInfo()
    }

    func togglePlayback() {
        if playerEngine.isPlaying {
            pausePlayback()
        } else {
            resumePlayback()
        }
    }

    func pausePlayback() {
        playerEngine.pause()
        self.isPlaying = false
        updateNowPlayingInfo()
    }

    func resumePlayback() {
        playerEngine.play()
        self.isPlaying = true
        updateNowPlayingInfo()
    }

    func seek(to time: Double) {
        playerEngine.seek(to: time)
        self.currentTime = time
        updateNowPlayingInfo()
    }

    func seekForward(by seconds: Double) {
        seek(to: currentTime + seconds)
    }

    func seekBackward(by seconds: Double) {
        seek(to: currentTime - seconds)
    }

    func stopPlayback() {
        playerEngine.stop()
        self.isPlaying = false
        self.currentTime = 0
        self.duration = 0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    func setVolume(_ value: Float) {
        volume = value
        playerEngine.engine.mainMixerNode.outputVolume = value
    }

    func toggleShuffle() {
        shuffle.toggle()
        print("🔀 Shuffle: \(shuffle ? "ON" : "OFF")")
    }

    func toggleRepeat() {
        repeatMode.toggle()
        print("🔁 Repeat: \(repeatMode ? "ON" : "OFF")")
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
            self?.nextSong()
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.previousSong()
            return .success
        }

        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            if let event = event as? MPChangePlaybackPositionCommandEvent {
                self?.seek(to: event.positionTime)
            }
            return .success
        }
    }

    private func updateNowPlayingInfo() {
        guard let song = currentSong else { return }
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: song.title,
            MPMediaItemPropertyArtist: song.artist,
            MPMediaItemPropertyAlbumTitle: song.album,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]

        if let image = song.albumImage ?? NSImage(systemSymbolName: "music.note", accessibilityDescription: nil) {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            info[MPMediaItemPropertyArtwork] = artwork
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}
