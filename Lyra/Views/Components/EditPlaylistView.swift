//
//  EditPlaylistView.swift
//  Lyra
//
//  Edit playlist metadata and cover
//

import SwiftUI
import PhotosUI

struct EditPlaylistView: View {
    let playlist: Playlist
    @StateObject private var library = MusicLibraryManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String
    @State private var selectedImage: PhotosPickerItem?
    @State private var coverImage: UIImage?
    
    init(playlist: Playlist) {
        self.playlist = playlist
        _name = State(initialValue: playlist.name)
        _coverImage = State(initialValue: playlist.coverImage)
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
                                    .fill(Color.purple.opacity(0.3))
                                    .frame(width: 180, height: 180)
                                    .overlay(
                                        Image(systemName: "music.note.list")
                                            .font(.system(size: 60))
                                            .foregroundColor(.purple)
                                    )
                            }
                            
                            PhotosPicker(selection: $selectedImage, matching: .images) {
                                Label("Choose Image", systemImage: "photo")
                            }
                            .buttonStyle(.bordered)
                            .tint(.purple)
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                Section("Playlist Info") {
                    TextField("Playlist Name", text: $name)
                }
            }
            .navigationTitle("Edit Playlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePlaylist()
                    }
                    .disabled(name.isEmpty)
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
    
    private func savePlaylist() {
        var updatedPlaylist = playlist
        updatedPlaylist.name = name
        
        if let image = coverImage {
            updatedPlaylist.coverImageData = image.jpegData(compressionQuality: 0.8)
        }
        
        library.updatePlaylist(updatedPlaylist)
        dismiss()
    }
}
