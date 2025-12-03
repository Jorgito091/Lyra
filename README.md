# Lyra - Music Player App

A full-featured music player application for iOS with background playback, playlist management, and custom cover art support.

## Features

### 🎵 Music Library
- Import MP3 files from Files app
- View all your music in a clean, organized library
- Search songs by title, artist, or album
- Edit song metadata (title, artist, album)
- Add custom cover art to songs
- Delete songs from library

### 📝 Playlist Management
- Create custom playlists
- Add personalized cover art to playlists (like Spotify)
- Add/remove songs from playlists
- Edit playlist names and covers
- Delete playlists

### 🎧 Playback Features
- Full background audio playback support
- Lock screen controls with album art
- Play/pause, skip forward/backward
- Seek through tracks
- Volume control with visual slider
- Shuffle mode for random playback
- Mini player for quick controls
- Continuous playback through playlists

### 🎨 User Interface
- Modern SwiftUI design
- Tab-based navigation
- Beautiful gradient backgrounds
- Smooth animations
- Dark mode support

## Architecture

### Models
- `Song.swift` - Song data model with metadata and cover art
- `Playlist.swift` - Playlist data model with custom covers

### Managers
- `AudioPlayerManager.swift` - Handles audio playback, background mode, and remote controls
- `MusicLibraryManager.swift` - Manages music library and playlists with persistence

### Views
- **Library** - Browse and manage your music collection
- **Playlists** - Create and manage playlists
- **Now Playing** - Full-screen playback interface
- **Components** - Reusable UI components

## Technical Details

### Background Audio
The app uses AVAudioPlayer with proper audio session configuration to enable:
- Background playback
- Lock screen controls
- Control Center integration
- Remote command handling (play, pause, skip, seek)

### Data Persistence
- Uses UserDefaults for storing song metadata and playlists
- MP3 files are copied to the app's Documents directory
- Cover images stored as JPEG data with compression

### File Import
- Document picker integration for MP3 import
- Multiple file selection support
- Security-scoped resource access

## Requirements
- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Usage

1. **Add Music**: Tap the "+" button in Library to import MP3 files
2. **Edit Songs**: Swipe left on any song to edit or delete
3. **Create Playlist**: Go to Playlists tab and tap "+"
4. **Customize Covers**: When creating/editing songs or playlists, tap "Choose Image" to add custom artwork
5. **Play Music**: Tap any song to start playback
6. **Background Mode**: Music continues playing when you lock your device or switch apps

## Customization

### Adding Custom Covers
You can add custom cover art to both individual songs and playlists:
- When editing a song or creating/editing a playlist
- Tap the "Choose Image" button
- Select an image from your Photos library
- The cover will be displayed throughout the app

### Volume Control
- Adjust playback volume using the slider in Now Playing view
- Volume settings are maintained across songs
- Visual feedback with speaker icons

### Shuffle Mode
- Enable shuffle to play songs in random order
- Toggle shuffle on/off with the shuffle button
- Maintains current song when enabling/disabling shuffle
- Original playback order is restored when shuffle is disabled

## Future Enhancements
- iCloud sync
- Equalizer
- Lyrics support
- Smart playlists
- Repeat modes (one/all)
- Queue management
- Sharing playlists
