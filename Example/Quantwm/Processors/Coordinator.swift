//
//  Coordinator.swift
//  deezer
//
//  Created by Xavier Lasne on 10/12/2017.
//  Copyright  MIT License
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
        dataModel.qwMediator.updateActionAndRefresh(owner: "Coordinator") {
        dataModel.qwMediator.registerObserver(
            registration: Coordinator.userIdUpdatedREG,
            target: self,
            selector: #selector(Coordinator.userIdUpdated))
        }
    }

    static let userIdUpdatedREG: QWRegistration = QWRegistration(
        smartWithReadMap: QWModel.root.userId_Read,
        name: "Coordinator.userIdUpdated",
        writtenMap: QWModel.root.playlistsCollection.all_Write +
            QWModel.root.selectedPlaylistId_Write +
            QWModel.root.trackListCollection.all_Write)

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
            let playlistIdArray = dataModel.playlistsCollection.playlistArray.map({$0.id})
            dataModel.trackListCollection.updateTracks(playlistIdArray: playlistIdArray)
            dataModel.networkMgr.getRxPlaylist(userId: userId)
        }
        dataModel.qwMediator.getCurrentObserverToken()?.displayUsage()
    }

}
