//
//  Coordinator.swift
//  deezer
//
//  Created by Xavier Lasne on 10/12/2017.
//  Copyright  MIT License
//

import Foundation
import Quantwm

// The normal role of this class is to update View Herarchy state, but the example is too simple.
// Here, it is to validate Data Model consistency after userId update

class Coordinator: ViewModel {

    init(mediator: Mediator) {
        super.init(mediator: mediator, owner: "Coordinator")
        qwMediator.updateActionAndRefresh(owner: "Coordinator") {
            qwMediator.registerObserver(
                registration: Coordinator.userIdUpdatedREG,
                target: self) {
                    [weak self] in
                    self?.userIdUpdated()
                }
        }
    }

    static let userIdUpdatedREG: QWRegistration = QWRegistration(
        hardWithReadMap: QWModel.root.userId_Read,
        name: "Coordinator.userIdUpdated",
        schedulingPriority: -2)

    var previousUserId: UserID? = nil

    @objc func userIdUpdated() {
        if dataModel.userId != previousUserId {
            previousUserId = dataModel.userId
            let userId = dataModel.userId
            dataModel.selectedPlaylistId = nil
            dataModel.playlistsCollection.updateUserId(userId: userId)
            let playlistIdArray = dataModel.playlistsCollection.playlistArray.map({$0.id})
            dataModel.trackListCollection.updateTracks(playlistIdArray: playlistIdArray)
        }
        qwMediator.getCurrentObserverToken()?.displayUsage()
    }

}
