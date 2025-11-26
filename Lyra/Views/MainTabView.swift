//
//  MainTabView.swift
//  Lyra
//
//  Main navigation with tab view
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var audioPlayer = AudioPlayerManager.shared
    @StateObject private var library = MusicLibraryManager.shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                LibraryView()
                    .tabItem {
                        Label("Library", systemImage: "music.note.list")
                    }
                
                PlaylistsView()
                    .tabItem {
                        Label("Playlists", systemImage: "music.note")
                    }
                
                NowPlayingView()
                    .tabItem {
                        Label("Now Playing", systemImage: "play.circle.fill")
                    }
            }
            .accentColor(.purple)
            
            // Mini player
            if audioPlayer.currentSong != nil {
                MiniPlayerView()
                    .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    MainTabView()
}
