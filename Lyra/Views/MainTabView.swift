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
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                LibraryView()
                    .tabItem {
                        Label("Library", systemImage: "music.note.list")
                    }
                    .tag(0)
                
                PlaylistsView()
                    .tabItem {
                        Label("Playlists", systemImage: "music.note")
                    }
                    .tag(1)
                
                NowPlayingView()
                    .tabItem {
                        Label("Now Playing", systemImage: "play.circle.fill")
                    }
                    .tag(2)
            }
            .accentColor(.gray)
            
            // Mini player
            if audioPlayer.currentSong != nil {
                MiniPlayerView(onTap: {
                    selectedTab = 2
                })
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    MainTabView()
}
