//
//  NowPlayingView.swift
//  Lyra
//
//  Created by Podz on 25/11/25.
//

import SwiftUI

struct NowPlayingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isPlaying: Bool = false
    @State private var progress: Double = 0.3
    
    let songTitle: String
    let artistName: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with close button
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("Now Playing")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Placeholder for symmetry
                Image(systemName: "ellipsis")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 32)
            
            Spacer()
            
            // Album artwork
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
                .frame(width: 280, height: 280)
                .overlay(
                    Image(systemName: "music.note")
                        .font(.system(size: 64))
                        .foregroundColor(.gray.opacity(0.3))
                )
            
            Spacer()
            
            // Song info
            VStack(spacing: 6) {
                Text(songTitle)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(artistName)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 24)
            
            // Progress bar
            VStack(spacing: 8) {
                Slider(value: $progress, in: 0...1)
                    .tint(.primary.opacity(0.6))
                
                HStack {
                    Text("0:00") // TODO: Replace with dynamic current time
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("--:--") // TODO: Replace with dynamic song duration
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            
            // Playback controls
            HStack(spacing: 48) {
                Button(action: {
                    // TODO: Implement previous track functionality
                }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.primary)
                }
                
                Button(action: {
                    isPlaying.toggle()
                }) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.primary)
                }
                
                Button(action: {
                    // TODO: Implement next track functionality
                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.primary)
                }
            }
            .padding(.top, 24)
            .padding(.bottom, 48)
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    NowPlayingView(songTitle: "Song Title", artistName: "Artist Name")
}
