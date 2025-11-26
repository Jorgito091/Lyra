//
//  ContentView.swift
//  Lyra
//
//  Created by Podz on 25/11/25.
//

import SwiftUI

struct Song: Identifiable {
    let id = UUID()
    let title: String
    let artist: String
    let duration: String
}

struct ContentView: View {
    @State private var isNowPlayingPresented: Bool = false
    @State private var currentSong: Song = Song(title: "No song playing", artist: "Unknown", duration: "0:00")
    
    let sampleSongs: [Song] = [
        Song(title: "Midnight Drive", artist: "The Echoes", duration: "3:42"),
        Song(title: "Silent Waves", artist: "Ocean Blue", duration: "4:15"),
        Song(title: "City Lights", artist: "Urban Dreams", duration: "3:28"),
        Song(title: "Mountain Air", artist: "Nature Sounds", duration: "5:02"),
        Song(title: "Quiet Storm", artist: "Jazz Collective", duration: "4:33")
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content
            NavigationStack {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(sampleSongs) { song in
                            SongRow(song: song) {
                                currentSong = song
                            }
                            
                            Divider()
                                .padding(.leading, 64)
                        }
                    }
                    .padding(.bottom, 80) // Space for mini player
                }
                .navigationTitle("Library")
                .navigationBarTitleDisplayMode(.large)
            }
            
            // Mini player bar at bottom
            MiniPlayerBar(
                isNowPlayingPresented: $isNowPlayingPresented,
                songTitle: currentSong.title,
                artistName: currentSong.artist
            )
        }
        .fullScreenCover(isPresented: $isNowPlayingPresented) {
            NowPlayingView(
                songTitle: currentSong.title,
                artistName: currentSong.artist
            )
        }
    }
}

struct SongRow: View {
    let song: Song
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Album artwork placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "music.note")
                            .font(.system(size: 18))
                            .foregroundColor(.gray.opacity(0.4))
                    )
                
                // Song info
                VStack(alignment: .leading, spacing: 4) {
                    Text(song.title)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(song.artist)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Text(song.duration)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
