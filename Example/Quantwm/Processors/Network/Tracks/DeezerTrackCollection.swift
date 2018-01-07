//
//  DeezerTracksCollection.swift
//  deezer
//
//  Created by Xavier Lasne on 02/12/2017.
//  Copyright  MIT License
//

import Foundation
import RxAlamofire
import RxSwift

// This class reads a track collection chunk for a given user.
// Can be stubbed using DeezerTrackAPI protocol

protocol DeezerTracksAPI {
    func getRxTrack(playlistId: PlaylistID)
    func subscribeToTrack(disposeBag: DisposeBag, completionHandler: @escaping (TrackChunk)->())
}

class DeezerTracks {

    // Publish a set of successive TrackChunk events after each getRxTrack() call
    let trackChunkPublisher = PublishSubject<TrackChunk>()

    // Release of track events
    // All the chunks of the request are released at the end of the request
    var tracksDisposeBagDict:[Int: DisposeBag] = [:]
    var trackRequestIndex: Int = 0

}

extension DeezerTracks: DeezerTracksAPI {

    //
    func subscribeToTrack(disposeBag: DisposeBag, completionHandler: @escaping (TrackChunk)->())
    {
        trackChunkPublisher.subscribe(
            onNext: {(indexedTrack: TrackChunk) in
                completionHandler(indexedTrack)
        }, onError: { (error: Error) in
            print("trackPublisher error:\(error)")
        }, onCompleted: {
            print("trackPublisher completed")
        }, onDisposed: {
            print("trackPublisher disposed")
        })
            .disposed(by: disposeBag)
    }


    func getRxTrack(playlistId: PlaylistID) {
        let stringUrl = "https://api.deezer.com/playlist/\(playlistId)/tracks"
        tracksDisposeBagDict[trackRequestIndex] = nil
        trackRequestIndex += 1
        tracksDisposeBagDict[trackRequestIndex] = DisposeBag()
        self.getRxTracksJSONChunk(playlistId: playlistId,
                                     requestIndex: trackRequestIndex,
                                     stringUrl: stringUrl)
    }

    // According to stackoverflow: https://stackoverflow.com/questions/46800763/deezer-api-nbtracks-total-not-reliable
    // checksum / total is not very reliable
    // -> Use the next only


    func getRxTracksJSONChunk(playlistId: PlaylistID, requestIndex: Int, stringUrl: String) {
        RxAlamofire.requestJSON(.get, stringUrl)
            .subscribe(onNext: { [weak self] (r, json) in
                if let dict = json as? [String: AnyObject] {
                    if let trackJsonChunk = TrackJSONChunk(dictionary: dict as NSDictionary) {
                        let trackChunk = trackJsonChunk.indexedTracks(playlistId: playlistId, index: requestIndex)
                        self?.trackChunkPublisher.onNext(trackChunk)
                        if let nextUrl = trackJsonChunk.next,
                            (requestIndex == self?.trackRequestIndex) {
                            self?.getRxTracksJSONChunk(playlistId: playlistId, requestIndex: requestIndex, stringUrl: nextUrl)
                        }
                    }
                }
                }, onError: { (error: Error) in
                    print("trackRequest error:\(error)")
            }, onCompleted: {
                print("trackRequest \(requestIndex) completed")
            }, onDisposed: {
                print("trackRequest \(requestIndex) disposed")
            })
            .disposed(by: tracksDisposeBagDict[requestIndex]!)
    }

}

