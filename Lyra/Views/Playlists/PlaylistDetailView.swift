//
//  PlaylistDetailView.swift
//  Lyra
//
//  Playlist detail view
//

import SwiftUI

struct PlaylistDetailView: View {
    let playlist: Playlist
    @StateObject private var library = MusicLibraryManager.shared
    @StateObject private var audioPlayer = AudioPlayerManager.shared
    @State private var showingAddSongs = false
    @State private var showingEditSheet = false
    
    var songs: [Song] {
        library.getSongsInPlaylist(playlist)
    }
    
    var body: some View {
        VStack {
            if songs.isEmpty {
                ContentUnavailableView {
                    Label("Empty Playlist", systemImage: "music.note")
                } description: {
                    Text("Add songs to this playlist")
                } actions: {
                    Button("Add Songs") {
                        showingAddSongs = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.gray)
                }
            } else {
                List {
                    // Playlist header
                    Section {
                        VStack(spacing: 16) {
                            if let coverImage = playlist.coverImage {
                                Image(uiImage: coverImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 180, height: 180)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 180, height: 180)
                                    .overlay(
                                        Image(systemName: "music.note")
                                            .font(.system(size: 60))
                                            .foregroundColor(.gray)
                                    )
                            }
                            
                            VStack(spacing: 4) {
                                Text(playlist.name)
                                    .font(.title2)
                                    .bold()
                                
                                Text("\(songs.count) songs")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(spacing: 20) {
                                Button {
                                    if !songs.isEmpty {
                                        audioPlayer.playSong(songs[0], from: songs)
                                    }
                                } label: {
                                    Label("Play", systemImage: "play.fill")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.gray)
                                
                                Button {
                                    showingEditSheet = true
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                    }
                    .listRowBackground(Color.clear)
                    
                    // Songs list
                    Section("Songs") {
                        ForEach(songs) { song in
                            SongRowView(song: song)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    audioPlayer.playSong(song, from: songs)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        library.removeSongFromPlaylist(songID: song.id, playlistID: playlist.id)
                                    } label: {
                                        Label("Remove", systemImage: "minus.circle")
                                    }
                                }
                        }
                    }
                }
            }
        }
        .navigationTitle(playlist.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddSongs = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSongs) {
            AddSongsToPlaylistView(playlist: playlist)
        }
        .sheet(isPresented: $showingEditSheet) {
            EditPlaylistView(playlist: playlist)
        }
    }
}
