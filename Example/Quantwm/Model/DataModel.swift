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

protocol MyModel {
    var dataModel: DataModel { get }
}

// Valid in the view hiearchy
extension MyModel {
    var dataModel: DataModel {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.dataModel!
    }
}

class DataModel : NSObject, QWRoot_S, QWMediatorOwner_S, QWNode_S  {
    
    static let debug_userID = 10
    
    unowned var networkMgr: DeezerAPI
    var coordinator: Coordinator = Coordinator()

    init(networkMgr: DeezerAPI) {
        
        self.networkMgr = networkMgr
        _userId = DataModel.debug_userID
        super.init()

        _playlistsCollection.updateUserId(userId: userId)

        qwMediator.registerRoot(
            qwRoot: self,
            rootProperty: DataModel.dataModelK)

    }
    
    var disposeBag = DisposeBag()

    func applicationBecomeActive() {
        qwMediator.updateActionAndRefresh(owner: self) {

            networkMgr.postInitialization(dataModel: self)

            networkMgr.subscribeToPlaylist(disposeBag: disposeBag) {[weak self] (indexedPlaylist: PlaylistChunk) in
                print("Data Model handler Playlist index:\(indexedPlaylist.index) count:\(indexedPlaylist.playlists.count)")
                if let me = self {
                    me.qwMediator.updateActionAndRefresh(owner: me) {
                        me.playlistsCollection.importChunck(chunk: indexedPlaylist)
                    }
                }
            }

            networkMgr.subscribeToTrack(disposeBag: disposeBag) {[weak self] (indexedTrack: TrackChunk) in
                print("Data Model handler Tracks index:\(indexedTrack.index) count:\(indexedTrack.data.count)")
                if let me = self {
                    me.qwMediator.updateActionAndRefresh(owner: me) {
                        me.trackCollection.importChunck(chunk: indexedTrack)
                    }
                }
            }

            coordinator.postInit(dataModel: self)
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
    //      |-trackCollection:TrackCollection - node
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
    fileprivate var _trackCollection : TrackCollection = TrackCollection()

    // MARK: - GETTER
    static let selectedPlaylistDependencies =
        QWModel.root.selectedPlaylistId_Read +
        PlaylistsCollection.playlistMap(root: QWModel.root.playlistsCollection)

    // sourcery: property
    // sourcery: readOnly
    // sourcery: dependency = "DataModel.selectedPlaylistDependencies"
    fileprivate var _selectedPlaylist: Playlist? {
        if let playlistId = selectedPlaylistId {
            return playlistsCollection.playlist(playlistId: playlistId)
        }
        return nil
    }

//    static let selectedTracklistDependencies =
//        QWModel.root.selectedPlaylistId_Read
//        + QWModel.root.trackCollection.trackDict.all_Read

//    static let selectedTracklistMap = QWModel.root.selectedTracklist.all_Read
//        + QWModel.root.selectedPlaylistId_Read
//        + QWModel.root.trackCollection.trackDict.all_Read

    // sourcery: node
    // sourcery: readOnly
    // sourcery: dependency = "QWModel.root.selectedPlaylistId_Read + QWModel.root.trackCollection.all_Read"
    fileprivate var _selectedTracklist: Tracklist? {
        if let playlistId = selectedPlaylistId {
            return trackCollection.trackDict[playlistId]
        }
        return nil
    }

    // MARK: - UPDATE
    func synchronizeTracksFromPlaylistCollection() {
        let playlistIdArray = playlistsCollection.playlistArray
        trackCollection.updateTracks(playlistIdArray: playlistIdArray)
    }


    // sourcery:inline:DataModel.QuantwmDeclarationInline

    // MARK: - Sourcery

    // QWMediatorOwner Protocol
    let qwMediator = QWMediator()
    func getQWMediator() -> QWMediator
    {
      return qwMediator
    }

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
    // Quantwm Node:  trackCollection
    static let trackCollectionK = QWNodeProperty(
        keypath: \DataModel.trackCollection,
        description: "_trackCollection")
    var trackCollection : TrackCollection {
      get {
        self.qwCounter.read(DataModel.trackCollectionK)
        return _trackCollection
      }
      set {
        self.qwCounter.write(DataModel.trackCollectionK)
        _trackCollection = newValue
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
