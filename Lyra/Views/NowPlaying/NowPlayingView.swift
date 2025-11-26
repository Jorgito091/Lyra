//
//  NowPlayingView.swift
//  Lyra
//
//  Now playing screen with playback controls
//

import SwiftUI

struct NowPlayingView: View {
    @StateObject private var audioPlayer = AudioPlayerManager.shared
    
    var body: some View {
        NavigationView {
            VStack {
                if let song = audioPlayer.currentSong {
                    ScrollView {
                        VStack(spacing: 32) {
                            // Album artwork
                            if let coverImage = song.coverImage {
                                Image(uiImage: coverImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 300, height: 300)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .shadow(radius: 10)
                            } else {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [.gray.opacity(0.6), .black],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 300, height: 300)
                                    .overlay(
                                        Image(systemName: "music.note")
                                            .font(.system(size: 100))
                                            .foregroundColor(.white.opacity(0.5))
                                    )
                                    .shadow(radius: 10)
                            }
                            
                            // Song info
                            VStack(spacing: 8) {
                                Text(song.title)
                                    .font(.title2)
                                    .bold()
                                    .multilineTextAlignment(.center)
                                
                                Text(song.artist)
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                                
                                Text(song.album)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            
                            // Progress slider
                            VStack(spacing: 8) {
                                Slider(
                                    value: Binding(
                                        get: { audioPlayer.currentTime },
                                        set: { audioPlayer.seek(to: $0) }
                                    ),
                                    in: 0...max(audioPlayer.duration, 0.1)
                                )
                                .accentColor(.gray)
                                
                                HStack {
                                    Text(audioPlayer.currentTime.formattedTime())
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text(audioPlayer.duration.formattedTime())
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal, 32)
                            
                            // Playback controls
                            HStack(spacing: 40) {
                                Button {
                                    audioPlayer.playPrevious()
                                } label: {
                                    Image(systemName: "backward.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.primary)
                                }
                                
                                Button {
                                    audioPlayer.togglePlayPause()
                                } label: {
                                    Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 72))
                                        .foregroundColor(.primary)
                                }
                                
                                Button {
                                    audioPlayer.playNext()
                                } label: {
                                    Image(systemName: "forward.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.primary)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 32)
                        .padding(.bottom, 100)
                    }
                } else {
                    ContentUnavailableView {
                        Label("No Song Playing", systemImage: "music.note")
                    } description: {
                        Text("Select a song from your library to start playing")
                    }
                }
            }
            .navigationTitle("Now Playing")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NowPlayingView()
}
