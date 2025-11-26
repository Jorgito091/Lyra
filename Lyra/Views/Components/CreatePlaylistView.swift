//
//  CreatePlaylistView.swift
//  Lyra
//
//  Create new playlist
//

import SwiftUI
import PhotosUI

struct CreatePlaylistView: View {
    @StateObject private var library = MusicLibraryManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var coverImage: UIImage?
    
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
                                        Image(systemName: "music.note.list")
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
                
                Section("Playlist Info") {
                    TextField("Playlist Name", text: $name)
                }
            }
            .navigationTitle("New Playlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createPlaylist()
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
    
    private func createPlaylist() {
        library.createPlaylist(name: name, coverImage: coverImage)
        dismiss()
    }
}

#Preview {
    CreatePlaylistView()
}
