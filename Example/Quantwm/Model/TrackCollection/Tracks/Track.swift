//
//  Track.swift
//  deezer
//
//  Created by Xavier on 03/12/2017.
//  Copyright © 2017 XL Software Solutions. => MIT License
//

import Foundation

typealias TrackId = Int

// Pure Immutable value type: No need of Quantwm monitoring

struct Track: Codable {
    let importIndex: Int

    let trackId : TrackId
    let title : String?
    let title_short : String?
    let artistName: String?
    let formattedDuration : String

    init?(index: Int, jsonTrack:TrackDataJSON) {
        guard let trackId = jsonTrack.id else { return nil }
        self.importIndex = index
        self.trackId = trackId
        self.title = jsonTrack.title
        self.formattedDuration = DurationFormater.formattedTime(durationInSeconds: jsonTrack.duration ?? 0)
        self.artistName = jsonTrack.artist?.name
        self.title_short = jsonTrack.title_short
    }

    //TODO: Provide normal / short title depending on input parameter label available space.
}


