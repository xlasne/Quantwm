
//
//  PlaylistTest.swift
//  deezerTests
//
//  Created by Xavier on 09/12/2017.
//  Copyright © 2017 XL Software Solutions. => MIT License
//

import XCTest

// import Pods_Quantwm_Tests
@testable import Quantwm_Example

class CheckPlaylist
{
    let playlist: Playlist

    init(playlist: Playlist) {
        self.playlist = playlist
    }

    func check(importIndex: Int) {
        XCTAssert(playlist.importIndex == importIndex)
        XCTAssert(playlist.id == 252588531)
        XCTAssert(playlist.title == "---- A découvrir")
        XCTAssert(playlist.duration == "00:34:57")
        XCTAssert(playlist.nb_tracks == 10)
        //TODO:  A compléter ...
    }
}


//case importIndex = "importIndex"
//case id = "id"
//case title = "title"
//case duration = "duration"
//case nb_tracks = "nb_tracks"
//case picture = "picture"
//case picture_small = "picture_small"
//case picture_medium = "picture_medium"
//case picture_big = "picture_big"
//case picture_xl = "picture_xl"
//case checksum = "checksum"
//case tracklist = "tracklist"
//case author = "creator"
//
//"checksum": "48b8c11f87a694baf577dc57a9c769e3",
//"collaborative": false,
//"creation_date": "0000-00-00 00:00:00",
//"creator": {
//    "id": 2529,
//    "name": "dadbond",
//    "tracklist": "https://api.deezer.com/user/2529/flow",
//    "type": "user"
//},
//"duration": 2097,
//"fans": 9,
//"id": 252588531,
//"is_loved_track": false,
//"link": "https://www.deezer.com/playlist/252588531",
//"nb_tracks": 10,
//"picture": "https://api.deezer.com/playlist/252588531/image",
//"picture_big": "https://e-cdns-images.dzcdn.net/images/playlist/8961c80799a4d93cba20abf3b1aa0648/500x500-000000-80-0-0.jpg",
//"picture_medium": "https://e-cdns-images.dzcdn.net/images/playlist/8961c80799a4d93cba20abf3b1aa0648/250x250-000000-80-0-0.jpg",
//"picture_small": "https://e-cdns-images.dzcdn.net/images/playlist/8961c80799a4d93cba20abf3b1aa0648/56x56-000000-80-0-0.jpg",
//"picture_xl": "https://e-cdns-images.dzcdn.net/images/playlist/8961c80799a4d93cba20abf3b1aa0648/1000x1000-000000-80-0-0.jpg",
//"public": true,
//"rating": 0,
//"title": "---- A découvrir",
//"tracklist": "https://api.deezer.com/playlist/252588531/tracks",
//"type": "playlist"
//}

