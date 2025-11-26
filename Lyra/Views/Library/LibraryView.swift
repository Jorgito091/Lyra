//
//  LibraryView.swift
//  Lyra
//
//  Music library view
//

import SwiftUI
import UniformTypeIdentifiers

struct LibraryView: View {
    @StateObject private var library = MusicLibraryManager.shared
    @StateObject private var audioPlayer = AudioPlayerManager.shared
    @State private var showingFilePicker = false
    @State private var selectedSong: Song?
    @State private var searchText = ""
    
    var filteredSongs: [Song] {
        if searchText.isEmpty {
            return library.songs
        } else {
            return library.songs.filter { song in
                song.title.localizedCaseInsensitiveContains(searchText) ||
                song.artist.localizedCaseInsensitiveContains(searchText) ||
                song.album.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if filteredSongs.isEmpty {
                    ContentUnavailableView {
                        Label("No Music", systemImage: "music.note")
                    } description: {
                        Text("Add some songs to get started")
                    } actions: {
                        Button("Add Music") {
                            showingFilePicker = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.gray)
                    }
                } else {
                    List {
                        ForEach(filteredSongs) { song in
                            SongRowView(song: song)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    audioPlayer.playSong(song, from: filteredSongs)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        library.deleteSong(song)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    Button {
                                        selectedSong = song
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search songs")
                }
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingFilePicker = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingFilePicker) {
                DocumentPicker()
            }
            .sheet(item: $selectedSong) { song in
                EditSongView(song: song)
            }
        }
    }
}

#Preview {
    LibraryView()
}
