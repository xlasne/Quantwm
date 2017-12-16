//
//  Coordinator.swift
//  deezer
//
//  Created by Xavier on 10/12/2017.
//  Copyright © 2017 XL Software Solutions. => MIT License
//

import Foundation
import Quantwm

// The role of this class is to validate Data Model consistency after inputs
// - UserID selection
// - Playlist Update
class Coordinator: NSObject {

    weak var dataModel: DataModel?

    // Shall be called after QWMediator is rooted
    func postInit(dataModel: DataModel)
    {
        self.dataModel = dataModel
        dataModel.qwMediator.updateAction(owner: self) {
        dataModel.qwMediator.registerObserver(
            target: self,
            registrationDesc: Coordinator.userIdUpdatedREG)
        }
    }

    static let userIdUpdatedREG: QWRegistration = QWRegistration(
        selector: #selector(Coordinator.userIdUpdated),
        readMap: QWModel.root.userId +
            QWModel.root.playlistsCollection.all +
            QWModel.root.selectedPlaylistId +
            QWModel.root.trackCollection.trackDict.all,
        name: "Coordinator.userIdUpdated",
        writtenMap: QWModel.root.playlistsCollection.allPaths() +
            QWModel.root.selectedPlaylistId +
            QWModel.root.trackCollection.trackDict.node,
        configurationPriority: -1)

    var previousUserId: UserID? = nil

    @objc func userIdUpdated() {
        guard let dataModel = dataModel else {
            assert(false, "dataModel not existing in Coordinator")
            return
        }
        if dataModel.userId != previousUserId {
            previousUserId = dataModel.userId
            let userId = dataModel.userId
            dataModel.selectedPlaylistId = nil
            dataModel.playlistsCollection.updateUserId(userId: userId)
            dataModel.synchronizeTracksFromPlaylistCollection()
            dataModel.networkMgr.getRxPlaylist(userId: userId)
        }
    }

}
