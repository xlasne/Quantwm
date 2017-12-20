//
//  DeezerNetworkStub.swift
//  deezerTests
//
//  Created by Xavier on 09/12/2017.
//  Copyright © 2017 XL Software Solutions. => MIT License
//

import Foundation
import RxSwift

@testable import Quantwm_Example

class NetworkStub: DeezerAPI {


    func postInit(dataModel: DataModel) {

    }

    func getRxPlaylist(userId: UserID) { }

    func subscribeToPlaylist(disposeBag: DisposeBag, completionHandler: @escaping (PlaylistChunk)->()) { }


    func getRxTrack(playlistId: PlaylistID) {}

    func subscribeToTrack(disposeBag: DisposeBag, completionHandler: @escaping (TrackChunk)->()) {}

}

