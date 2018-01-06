//
//  DataModel.swift
//  deezer
//
//  Created by Xavier on 02/12/2017.
//  Copyright © 2017 XL Software Solutions. => MIT License
//

import UIKit
import Foundation
import RxSwift
import Quantwm


class DataModel : QWRoot_S, QWNode_S  {

    static let debug_userID = 10

    unowned var networkMgr: DeezerAPI
    unowned var qwMediator: QWMediator<DataModel>

    var coordinator: Coordinator = Coordinator()

    init(networkMgr: DeezerAPI, qwMediator: QWMediator<DataModel>) {

        self.networkMgr = networkMgr
        self.qwMediator = qwMediator

        _userId = DataModel.debug_userID
        _playlistsCollection.updateUserId(userId: userId)

        qwMediator.registerRoot(
            model: self,
            rootProperty: DataModel.dataModelK)

        qwMediator.updateActionAndRefresh(owner: "DataModel") {
            networkMgr.postInit(dataModel: self)
            coordinator.postInit(dataModel: self)
        }
    }

    var disposeBag = DisposeBag()

    func applicationBecomeActive() {

        networkMgr.subscribeToPlaylist(disposeBag: disposeBag) {[weak self] (indexedPlaylist: PlaylistChunk) in
            print("Data Model handler Playlist index:\(indexedPlaylist.index) count:\(indexedPlaylist.playlists.count)")
            if let me = self {
                me.qwMediator.updateActionAndRefresh(owner: "DataModel") {
                    me.playlistsCollection.importChunck(chunk: indexedPlaylist)
                }
            }
        }

        networkMgr.subscribeToTrack(disposeBag: disposeBag) {[weak self] (indexedTrack: TrackChunk) in
            print("Data Model handler Tracks index:\(indexedTrack.index) count:\(indexedTrack.data.count)")
            if let me = self {
                me.qwMediator.updateActionAndRefresh(owner: "DataModel") {
                    me.trackListCollection.importChunck(chunk: indexedTrack)
                }
            }
        }

    }

    func applicationBecomeInactive() {
        disposeBag = DisposeBag()
    }

    // The model is:
    //   DataModel
    //      |
    //      |-playlistsCollection:PlaylistsCollection - node      -> PlaylistCollectionViewController.playlistUpdatedREG
    //      |      |
    //      |      |-playlistArray:[PlaylistID] - prop            -> PlaylistCollectionViewController.playlistUpdatedREG
    //      |      |
    //      |      L- playlistDict:[PlaylistID:Playlist] - prop   -> PlaylistCollectionViewController.playlistUpdatedREG
    //      |
    //      |-trackListCollection:TrackListCollection - node
    //      |      |
    //      |      |-trackDict: [PlaylistID:Tracklist] - prop     -> TracklistTableViewController.tracklistREG
    //      |
    //      |-selectedPlaylistId:PlaylistID? - prop               -> NetworkMgr.playlistSelectedREG
    //                                                            -> TracklistTableViewController.tracklistREG



    // MARK: - Quantwm Properties and Nodes

    // sourcery: root
    static let dataModelK = QWRootProperty(rootType: DataModel.self, rootId: "dataModel")

    // sourcery: property
    fileprivate var _userId : UserID

    // sourcery: property
    fileprivate var _selectedPlaylistId : PlaylistID?

    // sourcery: node
    fileprivate var _playlistsCollection : PlaylistsCollection = PlaylistsCollection()

    // sourcery: node
    fileprivate var _trackListCollection : TrackListCollection = TrackListCollection()


    // MARK: - Computed Properties
    // Shall be read-only
    // Dependencies shall be added manually and injected in Model via sourcery dependency annotation.

    static let selectedPlaylistDependencies =
        QWModel.root.selectedPlaylistId_Read +
        PlaylistsCollection.playlistsDataSourceMap(root: QWModel.root.playlistsCollection)

    // sourcery: property
    // sourcery: readOnly
    // sourcery: dependency = "DataModel.selectedPlaylistDependencies"
    fileprivate var _selectedPlaylist: Playlist? {
        if let playlistId = selectedPlaylistId {
            return playlistsCollection.playlist(playlistId: playlistId)
        }
        return nil
    }

    static let selectedTracklistDependencies =
        QWModel.root.selectedPlaylistId_Read
        + QWModel.root.trackListCollection.trackDict.all_Read

    // sourcery: node
    // sourcery: readOnly
    // sourcery: dependency = "DataModel.selectedTracklistDependencies"
    fileprivate var _selectedTracklist: Tracklist? {
        if let playlistId = selectedPlaylistId {
            return trackListCollection.trackDict[playlistId]
        }
        return nil
    }


    // sourcery:inline:DataModel.QuantwmDeclarationInline

    // MARK: - Sourcery

    // QWNode protocol
    func getQWCounter() -> QWCounter {
      return qwCounter
    }
    let qwCounter = QWCounter(name:"DataModel")
    func getPropertyArray() -> [QWProperty] {
        return DataModelQWModel.getPropertyArray()
    }


    // Quantwm Property: userId
    static let userIdK = QWPropProperty(
        propertyKeypath: \DataModel.userId,
        description: "_userId")
    var userId : UserID {
      get {
        self.qwCounter.read(DataModel.userIdK)
        return _userId
      }
      set {
        self.qwCounter.write(DataModel.userIdK)
        _userId = newValue
      }
    }
    // Quantwm Property: selectedPlaylistId
    static let selectedPlaylistIdK = QWPropProperty(
        propertyKeypath: \DataModel.selectedPlaylistId,
        description: "_selectedPlaylistId")
    var selectedPlaylistId : PlaylistID? {
      get {
        self.qwCounter.read(DataModel.selectedPlaylistIdK)
        return _selectedPlaylistId
      }
      set {
        self.qwCounter.write(DataModel.selectedPlaylistIdK)
        _selectedPlaylistId = newValue
      }
    }
    // Quantwm Node:  playlistsCollection
    static let playlistsCollectionK = QWNodeProperty(
        keypath: \DataModel.playlistsCollection,
        description: "_playlistsCollection")
    var playlistsCollection : PlaylistsCollection {
      get {
        self.qwCounter.read(DataModel.playlistsCollectionK)
        return _playlistsCollection
      }
      set {
        self.qwCounter.write(DataModel.playlistsCollectionK)
        _playlistsCollection = newValue
      }
    }
    // Quantwm Node:  trackListCollection
    static let trackListCollectionK = QWNodeProperty(
        keypath: \DataModel.trackListCollection,
        description: "_trackListCollection")
    var trackListCollection : TrackListCollection {
      get {
        self.qwCounter.read(DataModel.trackListCollectionK)
        return _trackListCollection
      }
      set {
        self.qwCounter.write(DataModel.trackListCollectionK)
        _trackListCollection = newValue
      }
    }
    // Quantwm Property: selectedPlaylist
    static let selectedPlaylistK = QWPropProperty(
        propertyKeypath: \DataModel.selectedPlaylist,
        description: "_selectedPlaylist")
    var selectedPlaylist : Playlist? {
      get {
        self.qwCounter.read(DataModel.selectedPlaylistK)
        return _selectedPlaylist
      }
    }
    // Quantwm Node:  selectedTracklist
    static let selectedTracklistK = QWNodeProperty(
        keypath: \DataModel.selectedTracklist,
        description: "_selectedTracklist")
    var selectedTracklist : Tracklist? {
      get {
        self.qwCounter.read(DataModel.selectedTracklistK)
        return _selectedTracklist
      }
    }

    // sourcery:end

}
