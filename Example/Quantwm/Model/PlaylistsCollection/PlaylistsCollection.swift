//
//  PlaylistsCollection.swift
//  deezer
//
//  Created by Xavier Lasne on 02/12/2017.
//  Copyright  MIT License
//

import Foundation
import Quantwm

typealias PlaylistID = Int

class PlaylistsCollection: QWNode_S, Codable {

    init() {
    }

    enum CodingKeys: String, CodingKey {
        case _playlistArray = "playlistArray"
        case _userId = "userId"
        case _total = "total"
    }

    fileprivate var _userId: UserID?

    // sourcery: property
    fileprivate var _playlistArray: [Playlist] = []

    // sourcery: property
    fileprivate var _total: Int = -1

    // MARK: - UPDATE
    var updateIndex: Int? = nil
    var neverUpdatedYet: Bool {
        return updateIndex == nil
    }
    var updatedPlaylistArray: [Playlist] = []

    func updateUserId(userId newUserId: UserID) {
        if _userId != newUserId {
            _userId = newUserId
            print("Playlist collection UserId \(newUserId) ")
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

        updatedPlaylistArray += newPlaylists

        if neverUpdatedYet {
            playlistArray = updatedPlaylistArray
            total = chunk.total
        }

        if chunk.lastChunk {
            playlistArray = updatedPlaylistArray
            total = updatedPlaylistArray.count
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
    func getPropertyArray() -> [QWProperty] {
        return PlaylistsCollectionQWModel.getPropertyArray()
    }


    // Quantwm Property: playlistArray
    static let playlistArrayK = QWPropProperty(
        propertyKeypath: \PlaylistsCollection.playlistArray,
        description: "_playlistArray")
    var playlistArray : [Playlist] {
      get {
        self.qwCounter.read(PlaylistsCollection.playlistArrayK)
        return _playlistArray
      }
      set {
        self.qwCounter.write(PlaylistsCollection.playlistArrayK)
        _playlistArray = newValue
      }
    }
    // Quantwm Property: total
    static let totalK = QWPropProperty(
        propertyKeypath: \PlaylistsCollection.total,
        description: "_total")
    var total : Int {
      get {
        self.qwCounter.read(PlaylistsCollection.totalK)
        return _total
      }
      set {
        self.qwCounter.write(PlaylistsCollection.totalK)
        _total = newValue
      }
    }
 
    // sourcery:end
}

extension PlaylistsCollection // Data Source
{

    // MARK: - GETTERS

    // Data Source for playlistArray
    static func playlistsDataSourceMap(root: PlaylistsCollectionQWModel) -> QWMap {
        return root.playlistArray_Read
    }

    var playlistsCount: Int {
        return playlistArray.count
    }

    func playlistForIndex(rowIndex: Int) -> Playlist? {
        if (0 <= rowIndex) && (rowIndex < playlistArray.count) {
            return playlistArray[rowIndex]
        }
        return nil
    }

    func playlist(playlistId: PlaylistID) -> Playlist? {
        return playlistArray.filter({$0.id == playlistId}).first
    }

}




