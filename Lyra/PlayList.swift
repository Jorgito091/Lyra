import Foundation

struct Playlist: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var imageData: Data?
    var songs: [SongItem]

    init(id: UUID = UUID(), name: String, imageData: Data? = nil, songs: [SongItem] = []) {
        self.id = id
        self.name = name
        self.imageData = imageData
        self.songs = songs
    }
}
