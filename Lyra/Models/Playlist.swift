//
//  Playlist.swift
//  Lyra
//
//  Playlist data model
//

import Foundation
import UIKit

struct Playlist: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var songIDs: [UUID]
    var coverImageData: Data?
    var dateCreated: Date
    var dateModified: Date
    
    init(id: UUID = UUID(), name: String, songIDs: [UUID] = [], coverImageData: Data? = nil, dateCreated: Date = Date(), dateModified: Date = Date()) {
        self.id = id
        self.name = name
        self.songIDs = songIDs
        self.coverImageData = coverImageData
        self.dateCreated = dateCreated
        self.dateModified = dateModified
    }
    
    var coverImage: UIImage? {
        guard let data = coverImageData else { return nil }
        return UIImage(data: data)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Playlist, rhs: Playlist) -> Bool {
        lhs.id == rhs.id
    }
}
