//
//  EditSongView.swift
//  Lyra
//
//  Edit song metadata and cover
//

import SwiftUI
import PhotosUI

struct EditSongView: View {
    let song: Song
    @StateObject private var library = MusicLibraryManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String
    @State private var artist: String
    @State private var album: String
    @State private var selectedImage: PhotosPickerItem?
    @State private var coverImage: UIImage?
    
    init(song: Song) {
        self.song = song
        _title = State(initialValue: song.title)
        _artist = State(initialValue: song.artist)
        _album = State(initialValue: song.album)
        _coverImage = State(initialValue: song.coverImage)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Cover Art") {
                    HStack {
                        Spacer()
                        VStack {
                            if let coverImage = coverImage {
                                Image(uiImage: coverImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 180, height: 180)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 180, height: 180)
                                    .overlay(
                                        Image(systemName: "music.note")
                                            .font(.system(size: 60))
                                            .foregroundColor(.gray)
                                    )
                            }
                            
                            PhotosPicker(selection: $selectedImage, matching: .images) {
                                Label("Choose Image", systemImage: "photo")
                            }
                            .buttonStyle(.bordered)
                            .tint(.gray)
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                Section("Song Info") {
                    TextField("Title", text: $title)
                    TextField("Artist", text: $artist)
                    TextField("Album", text: $album)
                }
            }
            .navigationTitle("Edit Song")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSong()
                    }
                }
            }
            .onChange(of: selectedImage) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        coverImage = image
                    }
                }
            }
        }
    }
    
    private func saveSong() {
        var updatedSong = song
        updatedSong.title = title
        updatedSong.artist = artist
        updatedSong.album = album
        
        if let image = coverImage {
            updatedSong.coverImageData = image.jpegData(compressionQuality: 0.8)
        }
        
        library.updateSong(updatedSong)
        dismiss()
    }
}
