//
//  MiniPlayerView.swift
//  Lyra
//
//  Mini player component shown at bottom
//

import SwiftUI

struct MiniPlayerView: View {
    @StateObject private var audioPlayer = AudioPlayerManager.shared
    
    var body: some View {
        if let song = audioPlayer.currentSong {
            HStack(spacing: 12) {
                // Cover art
                if let coverImage = song.coverImage {
                    Image(uiImage: coverImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 45, height: 45)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.purple.opacity(0.3))
                        .frame(width: 45, height: 45)
                        .overlay(
                            Image(systemName: "music.note")
                                .foregroundColor(.purple)
                                .font(.caption)
                        )
                }
                
                // Song info
                VStack(alignment: .leading, spacing: 2) {
                    Text(song.title)
                        .font(.subheadline)
                        .lineLimit(1)
                    
                    Text(song.artist)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Play/Pause button
                Button {
                    audioPlayer.togglePlayPause()
                } label: {
                    Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title3)
                        .foregroundColor(.purple)
                }
                
                // Next button
                Button {
                    audioPlayer.playNext()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
            )
            .padding(.horizontal)
        }
    }
}

#Preview {
    MiniPlayerView()
}
