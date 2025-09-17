import Foundation
import AVFoundation
import MediaPlayer
import AppKit

@MainActor  // ✅ Asegurar que todas las actualizaciones sean en el hilo principal
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
    private var playbackQueue: [SongItem] = [] // ✅ Cola de reproducción para shuffle

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
            let nextIndex: Int
            if shuffle {
                // Modo aleatorio: seleccionar canción aleatoria que no sea la actual
                var availableSongs = currentList.filter { $0.id != current.id }
                if availableSongs.isEmpty {
                    availableSongs = currentList // Si solo hay una canción, reproducirla de nuevo
                }
                nextIndex = Int.random(in: 0..<availableSongs.count)
                let nextSong = availableSongs[nextIndex]
                playSong(nextSong)
            } else {
                // Modo normal: siguiente canción o volver al inicio
                nextIndex = (index + 1) % currentList.count
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
            let previousIndex: Int
            if shuffle {
                // Modo aleatorio: seleccionar canción aleatoria que no sea la actual
                var availableSongs = currentList.filter { $0.id != current.id }
                if availableSongs.isEmpty {
                    availableSongs = currentList
                }
                previousIndex = Int.random(in: 0..<availableSongs.count)
                let previousSong = availableSongs[previousIndex]
                playSong(previousSong)
            } else {
                // Modo normal: canción anterior o ir al final
                previousIndex = index == 0 ? currentList.count - 1 : index - 1
                let previousSong = currentList[previousIndex]
                playSong(previousSong)
            }
        }
    }

    // MARK: - Reproducción
    func playSong(_ song: SongItem) {
        print("🎵 Reproduciendo: \(song.title) - ID: \(song.id.uuidString.prefix(8))")
        
        stopPlayback()
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: song.fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = volume
            
            // ✅ Asegurar que las actualizaciones de UI sean en el hilo principal
            Task { @MainActor in
                self.currentSong = song
                self.duration = self.audioPlayer?.duration ?? 0
                self.currentTime = 0
                self.isPlaying = true
                
                self.audioPlayer?.play()
                self.startTimer()
                self.updateNowPlayingInfo()
                
                print("🎵 Canción actual establecida: \(song.title)")
                print("🎵 Estado isPlaying: \(self.isPlaying)")
            }
        } catch {
            print("❌ Error al reproducir: \(error.localizedDescription)")
            Task { @MainActor in
                self.currentSong = nil
                self.isPlaying = false
            }
        }
    }

    func togglePlayback() {
        guard let player = audioPlayer else { return }
        if player.isPlaying {
            pausePlayback()
        } else {
            resumePlayback()
        }
    }

    func pausePlayback() {
        audioPlayer?.pause()
        Task { @MainActor in
            self.isPlaying = false
            self.stopTimer()
            self.updateNowPlayingInfo()
        }
    }

    func resumePlayback() {
        audioPlayer?.play()
        Task { @MainActor in
            self.isPlaying = true
            self.startTimer()
            self.updateNowPlayingInfo()
        }
    }

    func seek(to time: Double) {
        guard let player = audioPlayer else { return }
        let clamped = max(0, min(time, player.duration))
        player.currentTime = clamped
        Task { @MainActor in
            self.currentTime = clamped
            self.updateNowPlayingInfo()
        }
    }

    func seekForward(by seconds: Double) {
        seek(to: currentTime + seconds)
    }
    
    func seekBackward(by seconds: Double) {
        seek(to: currentTime - seconds)
    }

    func stopPlayback() {
        stopTimer()
        audioPlayer?.stop()
        audioPlayer = nil
        Task { @MainActor in
            self.isPlaying = false
            self.currentTime = 0
            self.duration = 0
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        }
    }

    func setVolume(_ value: Float) {
        volume = value
        audioPlayer?.volume = value
    }

    func toggleShuffle() {
        shuffle.toggle()
        print("🔀 Shuffle: \(shuffle ? "ON" : "OFF")")
    }
    
    func toggleRepeat() {
        repeatMode.toggle()
        print("🔁 Repeat: \(repeatMode ? "ON" : "OFF")")
    }

    // MARK: - Timer
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            
            // ✅ Actualizar en el hilo principal
            Task { @MainActor in
                self.currentTime = player.currentTime
                self.duration = player.duration
                
                // Solo actualizar NowPlayingInfo si hay cambios significativos
                if abs(player.currentTime - self.currentTime) > 1.0 {
                    self.updateNowPlayingInfo()
                }
            }
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
        print("🎵 Canción finalizada: \(currentSong?.title ?? "nil")")
        stopTimer()
        
        if repeatMode, let current = currentSong {
            print("🔁 Repitiendo canción actual")
            playSong(current)
        } else {
            print("⏭️ Pasando a siguiente canción")
            nextSong()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("❌ Error de decodificación: \(error?.localizedDescription ?? "desconocido")")
        stopPlayback()
    }
}
//CAMBIOS RELATIVOS AL URL DE YOUTUBE COM FMMPEG Y EL OTRO CACHARRO DE