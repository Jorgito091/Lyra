//
//  PlaylistRowView.swift
//  Lyra
//
//  Reusable playlist row component
//

import SwiftUI

struct PlaylistRowView: View {
    let playlist: Playlist
    @StateObject private var library = MusicLibraryManager.shared
    
    var songCount: Int {
        library.getSongsInPlaylist(playlist).count
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Cover art
            if let coverImage = playlist.coverImage {
                Image(uiImage: coverImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.purple.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "music.note.list")
                            .font(.title2)
                            .foregroundColor(.purple)
                    )
            }
            
            // Playlist info
            VStack(alignment: .leading, spacing: 4) {
                Text(playlist.name)
                    .font(.body)
                    .bold()
                    .lineLimit(1)
                
                Text("\(songCount) songs")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
