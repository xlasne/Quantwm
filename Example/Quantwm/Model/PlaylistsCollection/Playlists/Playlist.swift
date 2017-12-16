//
//  Playlist.swift
//  deezer
//
//  Created by Xavier on 02/12/2017.
//  Copyright © 2017 XL Software Solutions. => MIT License
//

import Foundation
import Quantwm

struct PlaylistKey: Hashable, Equatable {
    let id: PlaylistID
    let checksum: String
    var hashValue: Int {
        return id ^ checksum.hashValue
    }

    static func ==(lhs: PlaylistKey, rhs: PlaylistKey) -> Bool {
        return lhs.id == rhs.id && lhs.checksum == rhs.checksum
    }
}

final class Playlist: Codable {

    let importIndex: Int

    let id : Int
    let checksum : String

    let title : String?
    let duration : String
    let nb_tracks : Int?
    let picture : String?
    let picture_small : String?
    let picture_medium : String?
    let picture_big : String?
    let picture_xl : String?
    let tracklist : String?
    let author : String?

    enum CodingKeys: String, CodingKey {
        case importIndex = "importIndex"
        case id = "id"
        case title = "title"
        case duration = "duration"
        case nb_tracks = "nb_tracks"
        case picture = "picture"
        case picture_small = "picture_small"
        case picture_medium = "picture_medium"
        case picture_big = "picture_big"
        case picture_xl = "picture_xl"
        case checksum = "checksum"
        case tracklist = "tracklist"
        case author = "creator"
    }

    var key: PlaylistKey {
        return PlaylistKey(id: id, checksum: checksum)
    }

    init?(index: Int, json: PlaylistJSONData) {
        guard let playlistId = json.id else { return nil }
        guard let checksum = json.checksum else { return nil }
        self.importIndex = index
        self.id = playlistId
        self.checksum = checksum
        self.title = json.title
        self.duration = DurationFormater.formattedTime(durationInSeconds: json.duration ?? 0)
        self.nb_tracks = json.nb_tracks
        self.picture = json.picture
        self.picture_small = json.picture_small
        self.picture_medium = json.picture_medium
        self.picture_big = json.picture_big
        self.picture_xl = json.picture_xl
        self.tracklist = json.tracklist
        self.author = json.creator?.name
    }
}


// Example
//{
//    "checksum": "0d7597c64b5d4b10df0595abd3a017b2",
//    "collaborative": false,
//    "creation_date": "0000-00-00 00:00:00",
//    "creator": {
//        "id": 2529,
//        "name": "dadbond",
//        "tracklist": "https://api.deezer.com/user/2529/flow",
//        "type": "user"
//    },
//    "duration": 322,
//    "fans": 1,
//    "id": 609456965,
//    "is_loved_track": false,
//    "link": "https://www.deezer.com/playlist/609456965",
//    "nb_tracks": 1,
//    "picture": "https://api.deezer.com/playlist/609456965/image",
//    "picture_big": "https://e-cdns-images.dzcdn.net/images/cover/47f2aae6bd4b82f9d7d5940e7a4b2f3c/500x500-000000-80-0-0.jpg",
//    "picture_medium": "https://e-cdns-images.dzcdn.net/images/cover/47f2aae6bd4b82f9d7d5940e7a4b2f3c/250x250-000000-80-0-0.jpg",
//    "picture_small": "https://e-cdns-images.dzcdn.net/images/cover/47f2aae6bd4b82f9d7d5940e7a4b2f3c/56x56-000000-80-0-0.jpg",
//    "picture_xl": "https://e-cdns-images.dzcdn.net/images/cover/47f2aae6bd4b82f9d7d5940e7a4b2f3c/1000x1000-000000-80-0-0.jpg",
//    "public": true,
//    "rating": 0,
//    "title": "-- OLD Favourites --",
//    "tracklist": "https://api.deezer.com/playlist/609456965/tracks",
//    "type": "playlist"
//},


