//
//  TrackListCollection.swift
//  deezer
//
//  Created by Xavier on 09/12/2017.
//  Copyright © 2017 XL Software Solutions. => MIT License
//

import Foundation
import Quantwm

class TrackListCollection: QWNode_S, Codable {

    enum CodingKeys: String, CodingKey {
        case _trackDict = "trackDict"
    }

    // sourcery: node
    // sourcery: type = "Tracklist"
    fileprivate var _trackDict: [PlaylistID:Tracklist] = [:]


    //MARK: - UPDATE Tracks

    // On network response, update tracks by chunk
    // Tracks are refreshed by indexed chunk
    func importChunck(chunk: TrackChunk) {
        print("Track Collection: importChunck \(chunk.index) [\(chunk.data.count)] last: \(chunk.lastChunk)")

        // Retrieve the Tracks from the the chunk
        let tracksDelta:[Track] = chunk.data.flatMap({ Track(index:chunk.index, jsonTrack: $0) })

        // Find the Tracklist corresponding to this chunk, or create it if not existing
        let trackList = trackDict[chunk.playlistId] ?? Tracklist()

        // Add the tracks to this TrackList
        trackList.addTracks(importIndex: chunk.index, tracksArray: tracksDelta, lastChunk: chunk.lastChunk)
        trackDict[chunk.playlistId] = trackList
    }

    // On change of user id, cleanup the cache
    // and remove obsolete trackList.
    func updateTracks(playlistIdArray: [PlaylistID]) {
        for playlistId in trackDict.keys {
            if !playlistIdArray.contains(playlistId) {
                trackDict[playlistId] = nil
            }
        }
    }
    
    // sourcery:inline:TrackListCollection.QuantwmDeclarationInline

    // MARK: - Sourcery

    // QWNode protocol
    func getQWCounter() -> QWCounter {
      return qwCounter
    }
    let qwCounter = QWCounter(name:"TrackListCollection")
    func getPropertyArray() -> [QWProperty] {
        return TrackListCollectionQWModel.getPropertyArray()
    }


    // Quantwm Node:  trackDict
    static let trackDictK = QWNodeProperty(
        keypath: \TrackListCollection.trackDict,
        description: "_trackDict")
    var trackDict : [PlaylistID:Tracklist] {
      get {
        self.qwCounter.read(TrackListCollection.trackDictK)
        return _trackDict
      }
      set {
        self.qwCounter.write(TrackListCollection.trackDictK)
        _trackDict = newValue
      }
    }
    // sourcery:end

}
