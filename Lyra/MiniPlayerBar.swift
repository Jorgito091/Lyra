//
//  MiniPlayerBar.swift
//  Lyra
//
//  Created by Podz on 25/11/25.
//

import SwiftUI

struct MiniPlayerBar: View {
    @Binding var isNowPlayingPresented: Bool
    @State private var isPlaying: Bool = false
    
    let songTitle: String
    let artistName: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Album artwork placeholder
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "music.note")
                        .font(.system(size: 16))
                        .foregroundColor(.gray.opacity(0.6))
                )
            
            // Song info
            VStack(alignment: .leading, spacing: 2) {
                Text(songTitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(artistName)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Play/Pause button
            Button(action: {
                isPlaying.toggle()
            }) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Color(.systemBackground)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: -2)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            isNowPlayingPresented = true
        }
    }
}

#Preview {
    VStack {
        Spacer()
        MiniPlayerBar(
            isNowPlayingPresented: .constant(false),
            songTitle: "Song Title",
            artistName: "Artist Name"
        )
    }
}
