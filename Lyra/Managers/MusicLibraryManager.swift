//
//  MusicLibraryManager.swift
//  Lyra
//
//  Manages music library and playlists with persistence
//

import Foundation
import AVFoundation
import UIKit
import Combine

class MusicLibraryManager: ObservableObject {
    static let shared = MusicLibraryManager()
    
    @Published var songs: [Song] = []
    @Published var playlists: [Playlist] = []
    
    private let songsKey = "lyra_songs"
    private let playlistsKey = "lyra_playlists"
    
    private init() {
        loadData()
    }
    
    // MARK: - Song Management
    
    func addSong(from url: URL, title: String? = nil, artist: String? = nil, album: String? = nil, coverImage: UIImage? = nil) {
        // Copy file to app's documents directory
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to get documents directory")
            return
        }
        
        let fileName = url.lastPathComponent
        let destinationURL = documentsURL.appendingPathComponent("Music").appendingPathComponent(fileName)
        
        do {
            // Create Music directory if it doesn't exist
            try FileManager.default.createDirectory(at: documentsURL.appendingPathComponent("Music"), withIntermediateDirectories: true)
            
            // Copy file if it doesn't already exist
            if !FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.copyItem(at: url, to: destinationURL)
            }
            
            // Get audio metadata
            let asset = AVAsset(url: destinationURL)
            var songTitle = title ?? fileName.replacingOccurrences(of: ".mp3", with: "")
            var songArtist = artist ?? "Unknown Artist"
            var songAlbum = album ?? "Unknown Album"
            var duration: TimeInterval = 0
            
            // Extract metadata from file if available
            let metadata = asset.metadata
            for item in metadata {
                guard let commonKey = item.commonKey, let value = item.value else { continue }
                
                switch commonKey {
                case .commonKeyTitle:
                    if title == nil, let titleValue = value as? String {
                        songTitle = titleValue
                    }
                case .commonKeyArtist:
                    if artist == nil, let artistValue = value as? String {
                        songArtist = artistValue
                    }
                case .commonKeyAlbumName:
                    if album == nil, let albumValue = value as? String {
                        songAlbum = albumValue
                    }
                default:
                    break
                }
            }
            
            duration = CMTimeGetSeconds(asset.duration)
            
            let coverImageData = coverImage?.jpegData(compressionQuality: 0.8)
            
            let song = Song(
                title: songTitle,
                artist: songArtist,
                album: songAlbum,
                duration: duration,
                fileURL: destinationURL,
                coverImageData: coverImageData
            )
            
            songs.append(song)
            saveData()
        } catch {
            print("Failed to add song from file '\(fileName)': \(error.localizedDescription)")
        }
    }
    
    func updateSong(_ song: Song) {
        if let index = songs.firstIndex(where: { $0.id == song.id }) {
            objectWillChange.send()
            songs[index] = song
            saveData()
        }
    }
    
    func deleteSong(_ song: Song) {
        // Remove file
        try? FileManager.default.removeItem(at: song.fileURL)
        
        // Remove from songs array
        songs.removeAll { $0.id == song.id }
        
        // Remove from all playlists
        for i in 0..<playlists.count {
            playlists[i].songIDs.removeAll { $0 == song.id }
            playlists[i].dateModified = Date()
        }
        
        saveData()
    }
    
    func getSong(by id: UUID) -> Song? {
        return songs.first { $0.id == id }
    }
    
    // MARK: - Playlist Management
    
    func createPlaylist(name: String, coverImage: UIImage? = nil) {
        let coverImageData = coverImage?.jpegData(compressionQuality: 0.8)
        let playlist = Playlist(name: name, coverImageData: coverImageData)
        playlists.append(playlist)
        saveData()
    }
    
    func updatePlaylist(_ playlist: Playlist) {
        if let index = playlists.firstIndex(where: { $0.id == playlist.id }) {
            objectWillChange.send()
            var updatedPlaylist = playlist
            updatedPlaylist.dateModified = Date()
            playlists[index] = updatedPlaylist
            saveData()
        }
    }
    
    func deletePlaylist(_ playlist: Playlist) {
        playlists.removeAll { $0.id == playlist.id }
        saveData()
    }
    
    func addSongToPlaylist(songID: UUID, playlistID: UUID) {
        if let index = playlists.firstIndex(where: { $0.id == playlistID }) {
            if !playlists[index].songIDs.contains(songID) {
                playlists[index].songIDs.append(songID)
                playlists[index].dateModified = Date()
                saveData()
            }
        }
    }
    
    func removeSongFromPlaylist(songID: UUID, playlistID: UUID) {
        if let index = playlists.firstIndex(where: { $0.id == playlistID }) {
            playlists[index].songIDs.removeAll { $0 == songID }
            playlists[index].dateModified = Date()
            saveData()
        }
    }
    
    func getSongsInPlaylist(_ playlist: Playlist) -> [Song] {
        return playlist.songIDs.compactMap { getSong(by: $0) }
    }
    
    // MARK: - Persistence
    
    private func saveData() {
        // Save songs
        if let encoded = try? JSONEncoder().encode(songs) {
            UserDefaults.standard.set(encoded, forKey: songsKey)
        }
        
        // Save playlists
        if let encoded = try? JSONEncoder().encode(playlists) {
            UserDefaults.standard.set(encoded, forKey: playlistsKey)
        }
    }
    
    private func loadData() {
        // Load songs
        if let data = UserDefaults.standard.data(forKey: songsKey),
           let decoded = try? JSONDecoder().decode([Song].self, from: data) {
            // Validate that song files still exist
            songs = decoded.filter { song in
                FileManager.default.fileExists(atPath: song.fileURL.path)
            }
            
            // If any songs were filtered out, save the cleaned data
            if songs.count != decoded.count {
                print("Removed \(decoded.count - songs.count) songs with missing files")
                saveData()
            }
        }
        
        // Load playlists
        if let data = UserDefaults.standard.data(forKey: playlistsKey),
           let decoded = try? JSONDecoder().decode([Playlist].self, from: data) {
            playlists = decoded
            
            // Clean up any song references that no longer exist
            var playlistsModified = false
            for i in 0..<playlists.count {
                let originalCount = playlists[i].songIDs.count
                playlists[i].songIDs = playlists[i].songIDs.filter { songID in
                    songs.contains(where: { $0.id == songID })
                }
                if playlists[i].songIDs.count != originalCount {
                    playlistsModified = true
                }
            }
            
            if playlistsModified {
                print("Cleaned up playlist references to missing songs")
                saveData()
            }
        }
    }
}
