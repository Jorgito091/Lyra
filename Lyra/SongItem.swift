import Foundation
import AppKit

struct SongItem: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var artist: String
    var album: String
    var fileURL: URL
    var albumImageData: Data? // portada

    var albumImage: NSImage? {
        guard let data = albumImageData else { return nil }
        return NSImage(data: data)
    }

    init(id: UUID = UUID(), title: String, artist: String, album: String, fileURL: URL, albumImageData: Data? = nil) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.fileURL = fileURL
        self.albumImageData = albumImageData
    }
}
