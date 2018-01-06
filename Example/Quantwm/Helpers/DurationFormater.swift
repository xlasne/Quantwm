//
//  DurationFormater.swift
//  deezer
//
//  Created by Xavier Lasne on 03/12/2017.
//  Copyright  MIT License
//

import Foundation

class DurationFormater {

    static func formattedTime(durationInSeconds: Int?) -> String {
        guard let durationInSeconds  = durationInSeconds,
            durationInSeconds >= 0 else {
            return "..:..:.."
        }

        let seconds = durationInSeconds % 60
        let minutes = (durationInSeconds/60) % 60
        let hours = (durationInSeconds/(60*60))

        let timeString = String(format:"%02d:%02d:%02d", hours, minutes, seconds)
        return timeString
    }

}
