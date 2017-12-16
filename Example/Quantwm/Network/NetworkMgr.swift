//
//  NetworkMgr.swift
//  deezer
//
//  Created by Xavier on 02/12/2017.
//  Copyright © 2017 XL Software Solutions. => MIT License
//

import Foundation
import Alamofire
import AlamofireImage
import RxAlamofire
import RxSwift
import Quantwm

protocol DeezerAPI: class, DeezerTracksAPI, DeezerPlaylistAPI {
    func postInitialization(dataModel: DataModel)
}

//TODO: Reachability
//TODO: Network conditioning tests

class NetworkMgr: NSObject, DeezerAPI {

    //MARK: - Init & configuration

    weak var dataModel: DataModel? = nil
    let deezerPlaylist = DeezerPlaylist()
    let deezerTracks = DeezerTracks()

    // AlamofireImage Default configuration:
    // Image Cache 100 MB, 4 parallel downloads
    let imageDownloader = ImageDownloader(
        configuration: ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .lifo,
        maximumActiveDownloads: 4,
        imageCache: AutoPurgingImageCache()
    )

    func clearImageCache() {
        imageDownloader.imageCache?.removeAllImages()
    }

    override init() {
        super.init()
    }

    // To be called just after application launch
    func postInitialization(dataModel: DataModel) {
        self.dataModel = dataModel
        dataModel.getQWMediator().registerObserver(target: self,
                                                   registrationDesc: NetworkMgr.playlistSelectedREG)
    }

    //MARK: - GET Request: Set of tracks of selected playlist
    // Triggered by the selection of a playlist

    static let playlistSelectedREG: QWRegistration = QWRegistration(
        selector: #selector(NetworkMgr.loadSelectedPlaylistTracks),
        readMap: QWModel.root.selectedPlaylistId,
        name: "NetworkMgr.loadSelectedPlaylistTracks")

    @objc func loadSelectedPlaylistTracks() {
        if let playlistId = dataModel?.selectedPlaylistId {
            self.getRxTrack(playlistId: playlistId)
        }
    }
}

extension NetworkMgr: DeezerPlaylistAPI {
    func getRxPlaylist(userId: UserID) {
        clearImageCache()
        deezerPlaylist.getRxPlaylist(userId: userId)
    }

    func subscribeToPlaylist(disposeBag: DisposeBag, completionHandler: @escaping (PlaylistChunk) -> ()) {
        deezerPlaylist.subscribeToPlaylist(disposeBag: disposeBag,
                                           completionHandler: completionHandler)
    }
}

extension NetworkMgr: DeezerTracksAPI {
    func getRxTrack(playlistId: PlaylistID) {
        deezerTracks.getRxTrack(playlistId: playlistId)
    }

    func subscribeToTrack(disposeBag: DisposeBag, completionHandler: @escaping (TrackChunk) -> ()) {
        deezerTracks.subscribeToTrack(disposeBag: disposeBag, completionHandler: completionHandler)
    }
}
