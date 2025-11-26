//
//  AddSongsToPlaylistView.swift
//  Lyra
//
//  Add songs to playlist
//

import SwiftUI

struct AddSongsToPlaylistView: View {
    let playlist: Playlist
    @StateObject private var library = MusicLibraryManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedSongs: Set<UUID> = []
    
    var availableSongs: [Song] {
        library.songs.filter { !playlist.songIDs.contains($0.id) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if availableSongs.isEmpty {
                    ContentUnavailableView {
                        Label("No Songs Available", systemImage: "music.note")
                    } description: {
                        Text("All songs are already in this playlist")
                    }
                } else {
                    List(availableSongs) { song in
                        HStack {
                            SongRowView(song: song)
                            
                            Spacer()
                            
                            if selectedSongs.contains(song.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.gray)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedSongs.contains(song.id) {
                                selectedSongs.remove(song.id)
                            } else {
                                selectedSongs.insert(song.id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Songs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add (\(selectedSongs.count))") {
                        addSongs()
                    }
                    .disabled(selectedSongs.isEmpty)
                }
            }
        }
    }
    
    private func addSongs() {
        for songID in selectedSongs {
            library.addSongToPlaylist(songID: songID, playlistID: playlist.id)
        }
        dismiss()
    }
}
