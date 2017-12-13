//
//  TrackCollection.swift
//  deezer
//
//  Created by Xavier on 09/12/2017.
//  Copyright © 2017 XL Software Solutions. All rights reserved.
//

import Foundation
import Quantwm

class Tracklist: QWNode_S, Codable {

    // sourcery:inline:Tracklist.QuantwmDeclarationInline

    // MARK: - Sourcery

    // QWNode protocol
    func getQWCounter() -> QWCounter {
      return qwCounter
    }
    let qwCounter = QWCounter(name:"Tracklist")

    // Quantwm Property Array generation
    func getQWPropertyArray() -> [QWProperty] {
        return Tracklist.qwPropertyArrayK
    }
    static let qwPropertyArrayK:[QWProperty] = [
      finalTracksArrayK,  // property
    ]
    // Quantwm Property: finalTracksArray
    static let finalTracksArrayK = QWProperty(
        propertyKeypath: \Tracklist.finalTracksArray,
        description: "_finalTracksArray")
    var finalTracksArray : [Track] {
      get {
        self.qwCounter.performedReadOnMainThread(Tracklist.finalTracksArrayK)
        return _finalTracksArray
      }
      set {
        self.qwCounter.performedWriteOnMainThread(Tracklist.finalTracksArrayK)
        _finalTracksArray = newValue
      }
    }
    // sourcery:end


    private var _finalImportIndex: Int? = nil

    // sourcery: property
    private var _finalTracksArray: [Track] = []

    private var _inProgressImportIndex: Int? = nil
    private var _inProgressTracksArray: [Track] = []

    func addTracks(importIndex: Int, tracksArray: [Track], lastChunk: Bool) {
        if importIndex != _inProgressImportIndex {
            _inProgressImportIndex = importIndex
            _inProgressTracksArray = []
        }
        _inProgressTracksArray += tracksArray
        if _finalImportIndex == nil {
            // If nothing present, start displaying in progress download.
            finalTracksArray = _inProgressTracksArray
        }
        if lastChunk {
            _finalImportIndex = _inProgressImportIndex
            finalTracksArray = _inProgressTracksArray
            _inProgressImportIndex = importIndex
            _inProgressTracksArray = []
        }
    }

    var tracksArray: [Track] {
        return finalTracksArray
    }


}

class TrackCollection: QWNode_S, Codable {

    init() {
    }

    enum CodingKeys: String, CodingKey {
        case _trackDict = "trackDict"
    }

    static let trackDictAllPath: QWPath = trackDictPath.all()
    static let trackDictAllMap: QWMap = trackDictAllPath.map

    // sourcery: node
    var _trackDict: [PlaylistID:Tracklist] = [:]

    // sourcery: rootpath
    static let rootPath = QWPath(root: DataModel.dataModelK, chain:[DataModel.trackCollectionK])

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _trackDict = try values.decode([PlaylistID:Tracklist].self, forKey: ._trackDict)
    }

    // MARK: - UPDATE

    //MARK: - UPDATE Tracks

    // Tracks are refreshed by indexed chunk
    func importChunck(chunk: TrackChunk) {
        print("Track Collection: importChunck \(chunk.index) [\(chunk.data.count)] last: \(chunk.lastChunk)")
        let tracksDelta:[Track] = chunk.data.flatMap({ Track(index:chunk.index, jsonTrack: $0) })
        let trackList = trackDict[chunk.playlistId] ?? Tracklist()
        trackList.addTracks(importIndex: chunk.index, tracksArray: tracksDelta, lastChunk: chunk.lastChunk)
        trackDict[chunk.playlistId] = trackList
    }

    func updateTracks(playlistIdArray: [PlaylistID]) {
        for playlistId in trackDict.keys {
            if !playlistIdArray.contains(playlistId) {
                trackDict[playlistId] = nil
            }
        }
    }

    // sourcery:inline:TrackCollection.QuantwmDeclarationInline

    // MARK: - Sourcery

    // QWNode protocol
    func getQWCounter() -> QWCounter {
      return qwCounter
    }
    let qwCounter = QWCounter(name:"TrackCollection")

    // Quantwm Property Array generation
    func getQWPropertyArray() -> [QWProperty] {
        return TrackCollection.qwPropertyArrayK
    }
    static let qwPropertyArrayK:[QWProperty] = [
      trackDictK,   // node
    ]
    // Quantwm Path and Map generation
    static let trackDictPath: QWPath = rootPath.appending(TrackCollection.trackDictK)
    static let trackDictMap: QWMap = trackDictPath.map

    // Quantwm Node:  trackDict
    static let trackDictK = QWNodeProperty(
        keypath: \TrackCollection.trackDict,
        description: "_trackDict")
    var trackDict : [PlaylistID:Tracklist] {
      get {
        self.qwCounter.performedReadOnMainThread(TrackCollection.trackDictK)
        return _trackDict
      }
      set {
        self.qwCounter.performedWriteOnMainThread(TrackCollection.trackDictK)
        _trackDict = newValue
      }
    }
    // sourcery:end

}
