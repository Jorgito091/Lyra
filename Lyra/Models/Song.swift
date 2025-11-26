//
//  Song.swift
//  Lyra
//
//  Music data model
//

import Foundation
import UIKit

struct Song: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var artist: String
    var album: String
    var duration: TimeInterval
    var fileURL: URL
    var coverImageData: Data?
    var dateAdded: Date
    
    init(id: UUID = UUID(), title: String, artist: String = "Unknown Artist", album: String = "Unknown Album", duration: TimeInterval = 0, fileURL: URL, coverImageData: Data? = nil, dateAdded: Date = Date()) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.duration = duration
        self.fileURL = fileURL
        self.coverImageData = coverImageData
        self.dateAdded = dateAdded
    }
    
    var coverImage: UIImage? {
        guard let data = coverImageData else { return nil }
        return UIImage(data: data)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Song, rhs: Song) -> Bool {
        lhs.id == rhs.id
    }
}
