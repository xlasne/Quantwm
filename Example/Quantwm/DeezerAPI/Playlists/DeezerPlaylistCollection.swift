//
//  DeezerPlaylistsCollection.swift
//  deezer
//
//  Created by Xavier on 02/12/2017.
//  Copyright © 2017 XL Software Solutions. All rights reserved.
//

import Foundation
import RxAlamofire
import RxSwift

typealias UserID = Int

// This class reads a playlist collection chunk for a given user.
// Can be stubbed using DeezerPlaylistAPI protocol

protocol DeezerPlaylistAPI {
    func getRxPlaylist(userId: UserID)
    func subscribeToPlaylist(disposeBag: DisposeBag, completionHandler: @escaping (PlaylistChunk)->())
}

class DeezerPlaylist {

    // Publish a set of successive PlaylistChunk events after each getRxPlaylist() call
    let playlistChunkPublisher = PublishSubject<PlaylistChunk>()

    // Release of playlist events
    // All the chunks of the request are released at the end of the request
    var playlistsDisposeBagDict:[Int: DisposeBag] = [:]
    var playlistRequestIndex: Int = 0

}

extension DeezerPlaylist: DeezerPlaylistAPI {

    //
    func subscribeToPlaylist(disposeBag: DisposeBag, completionHandler: @escaping (PlaylistChunk)->())
    {
        playlistChunkPublisher.subscribe(
            onNext: {(indexedPlaylist: PlaylistChunk) in
                completionHandler(indexedPlaylist)
        }, onError: { (error: Error) in
            print("playlistPublisher error:\(error)")
        }, onCompleted: {
            print("playlistPublisher completed")
        }, onDisposed: {
            print("playlistPublisher disposed")
        })
            .disposed(by: disposeBag)
    }


    func getRxPlaylist(userId: UserID) {
        let stringUrl = "https://api.deezer.com/user/\(userId)/playlists"
        playlistsDisposeBagDict[playlistRequestIndex] = nil
        playlistRequestIndex += 1
        playlistsDisposeBagDict[playlistRequestIndex] = DisposeBag()
        self.getRxPlaylistsJSONChunk(userId: userId,
                                     requestIndex: playlistRequestIndex,
                                     stringUrl: stringUrl)
    }

    // According to stackoverflow: https://stackoverflow.com/questions/46800763/deezer-api-nbtracks-total-not-reliable
    // checksum / total is not very reliable
    // -> Use the next only

    func getRxPlaylistsJSONChunk(userId: UserID, requestIndex: Int, stringUrl: String) {
        RxAlamofire.requestJSON(.get, stringUrl)
            .subscribe(onNext: { [weak self] (r, json) in
                if let dict = json as? [String: AnyObject] {
                    if let playlistJsonChunk = PlaylistsJSONChunk(dictionary: dict as NSDictionary) {
                        let playlistChunk = playlistJsonChunk.indexedPlaylists(userId: userId, index: requestIndex)
                        self?.playlistChunkPublisher.onNext(playlistChunk)
                        if let nextUrl = playlistJsonChunk.next,
                            (requestIndex == self?.playlistRequestIndex) {
                            self?.getRxPlaylistsJSONChunk(userId: userId, requestIndex: requestIndex, stringUrl: nextUrl)
                        }
                    }
                }
                }, onError: { (error: Error) in
                    print("playlistRequest error:\(error)")
            }, onCompleted: {
                print("playlistRequest \(requestIndex) completed")
            }, onDisposed: {
                print("playlistRequest \(requestIndex) disposed")
            })
            .disposed(by: playlistsDisposeBagDict[requestIndex]!)
    }

}

