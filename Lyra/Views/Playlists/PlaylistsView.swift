//
//  PlaylistsView.swift
//  Lyra
//
//  Playlists management view
//

import SwiftUI

struct PlaylistsView: View {
    @StateObject private var library = MusicLibraryManager.shared
    @State private var showingCreateSheet = false
    @State private var selectedPlaylist: Playlist?
    
    var body: some View {
        NavigationView {
            VStack {
                if library.playlists.isEmpty {
                    ContentUnavailableView {
                        Label("No Playlists", systemImage: "music.note")
                    } description: {
                        Text("Create a playlist to organize your music")
                    } actions: {
                        Button("Create Playlist") {
                            showingCreateSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.gray)
                    }
                } else {
                    List {
                        ForEach(library.playlists) { playlist in
                            NavigationLink(destination: PlaylistDetailView(playlist: playlist)) {
                                PlaylistRowView(playlist: playlist)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    library.deletePlaylist(playlist)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Playlists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreateSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreatePlaylistView()
            }
        }
    }
}

#Preview {
    PlaylistsView()
}
