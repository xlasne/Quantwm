//
//  PlaylistsCollection.swift
//  deezer
//
//  Created by Xavier on 02/12/2017.
//  Copyright © 2017 XL Software Solutions. All rights reserved.
//

import Foundation
import Quantwm

typealias PlaylistID = Int

class PlaylistsCollection: QWNode_S, Codable {

    init() {
    }

    enum CodingKeys: String, CodingKey {
        case _playlistArray = "playlistArray"
        case _playlistDict = "playlistDict"
        case _userId = "userId"
        case _total = "total"
    }

    // Best practice: Storing playlist order and playlist content separately
    // Change of order, insertion, deletion does not trigger refresh of Playlist ID based content.

    var _userId: UserID?

    // sourcery: property
    var _playlistArray: [PlaylistID] = []

    // sourcery: property
    var _playlistDict: [PlaylistID:Playlist] = [:]

    // sourcery: property
    var _total: Int = -1

    // sourcery: rootpath
    static let rootPath = QWPath(root: DataModel.dataModelK, chain:[DataModel.playlistsCollectionK])

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _playlistArray = try values.decode([PlaylistID].self, forKey: ._playlistArray)
        _playlistDict = try values.decode([PlaylistID:Playlist].self, forKey: ._playlistDict)
        _userId = try values.decode(UserID.self, forKey: ._userId)
        _total = try values.decode(Int.self, forKey: ._total)
    }


    // MARK: - UPDATE
    var updateIndex: Int?
    var updatedPlaylistArray: [PlaylistID] = []

    func updateUserId(userId newUserId: UserID) {
        if _userId != newUserId {
            _userId = newUserId
            print("Playlist collection UserId \(newUserId) ")
            playlistDict = [:]
            playlistArray = []
            updateIndex = nil
            updatedPlaylistArray = []
            total = -1
        }
    }

    // Playlists are refreshed by chunk
    // On the last chunk, playlist which have been removed are effectively removed.
    func importChunck(chunk: PlaylistChunk) {

        if chunk.userId != _userId {
            // Ignore old chunks
            return
        }

        let newPlaylists:[Playlist] = chunk.playlists.flatMap({ Playlist(index:chunk.index, json: $0) })

        for playlist in newPlaylists {
            playlistDict[playlist.id] = playlist
            updatedPlaylistArray.append(playlist.id)
        }

        if updateIndex == nil {
            playlistArray = updatedPlaylistArray
            total = chunk.total
        }

        if chunk.lastChunk {
            playlistArray = updatedPlaylistArray
            total = updatedPlaylistArray.count
            playlistDict = playlistDict.filter({ (key: PlaylistID, playlist: Playlist) -> Bool in
                return playlistArray.contains(key)
            })
            assert(playlistArray.count == playlistDict.keys.count, "Inconsistent playlist")
            updatedPlaylistArray = []
            updateIndex = chunk.index
        }
    }


    // sourcery:inline:PlaylistsCollection.QuantwmDeclarationInline

    // MARK: - Sourcery

    // QWNode protocol
    func getQWCounter() -> QWCounter {
      return qwCounter
    }
    let qwCounter = QWCounter(name:"PlaylistsCollection")

    // Quantwm Property Array generation
    func getQWPropertyArray() -> [QWProperty] {
        return PlaylistsCollection.qwPropertyArrayK
    }
    static let qwPropertyArrayK:[QWProperty] = [
      playlistArrayK,  // property
      playlistDictK,  // property
      totalK,  // property
    ]
    // Quantwm Path and Map generation
    static let playlistArrayPath: QWPath = rootPath.appending(PlaylistsCollection.playlistArrayK)
    static let playlistArrayMap: QWMap = playlistArrayPath.map

    static let playlistDictPath: QWPath = rootPath.appending(PlaylistsCollection.playlistDictK)
    static let playlistDictMap: QWMap = playlistDictPath.map

    static let totalPath: QWPath = rootPath.appending(PlaylistsCollection.totalK)
    static let totalMap: QWMap = totalPath.map

    // Quantwm Property: playlistArray
    static let playlistArrayK = QWProperty(
        propertyKeypath: \PlaylistsCollection.playlistArray,
        description: "_playlistArray")
    var playlistArray : [PlaylistID] {
      get {
        self.qwCounter.performedReadOnMainThread(PlaylistsCollection.playlistArrayK)
        return _playlistArray
      }
      set {
        self.qwCounter.performedWriteOnMainThread(PlaylistsCollection.playlistArrayK)
        _playlistArray = newValue
      }
    }
    // Quantwm Property: playlistDict
    static let playlistDictK = QWProperty(
        propertyKeypath: \PlaylistsCollection.playlistDict,
        description: "_playlistDict")
    var playlistDict : [PlaylistID:Playlist] {
      get {
        self.qwCounter.performedReadOnMainThread(PlaylistsCollection.playlistDictK)
        return _playlistDict
      }
      set {
        self.qwCounter.performedWriteOnMainThread(PlaylistsCollection.playlistDictK)
        _playlistDict = newValue
      }
    }
    // Quantwm Property: total
    static let totalK = QWProperty(
        propertyKeypath: \PlaylistsCollection.total,
        description: "_total")
    var total : Int {
      get {
        self.qwCounter.performedReadOnMainThread(PlaylistsCollection.totalK)
        return _total
      }
      set {
        self.qwCounter.performedWriteOnMainThread(PlaylistsCollection.totalK)
        _total = newValue
      }
    }
 
    // sourcery:end
}

extension PlaylistsCollection // Data Source
{

    // MARK: - GETTERS

    // RefreshUI Access: register to playlistArrayMap
    var playlistsCount: Int {
        return playlistArray.count
    }

    // RefreshUI Access: register to playlistDictMap / playlistArrayMap
    func playlist(rowIndex: Int) -> Playlist? {
        if (0 <= rowIndex) && (rowIndex < playlistArray.count) {
            let playlistID = playlistArray[rowIndex]
            return playlistDict[playlistID]
        }
        return nil
    }

    // RefreshUI Access: register to playlistDictMap
    func playlist(playlistId: PlaylistID) -> Playlist? {
        return playlistDict[playlistId]
    }

}




