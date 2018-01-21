//
//  PlaylistHeaderViewModel.swift
//  deezer
//
//  Created by Xavier Lasne on 03/12/2017.
//  Copyright  MIT License
//

import UIKit
import Quantwm

class PlaylistHeaderViewModel: ViewModel
{

    func playlistHeaderInfoSelectedPlaylist() -> PlaylistHeaderInfo? {
        if let playlistId = dataModel.selectedPlaylistId,
            let playlist = dataModel.playlistsCollection.playlist(playlistId: playlistId) {
            var imageUrl:URL? = nil
            var largeImageUrl:URL? = nil
            if let urlStr = playlist.picture_medium {
                imageUrl = URL(string: urlStr)
            }
            if let urlStr = playlist.picture_big {
                largeImageUrl = URL(string: urlStr)
            }
            var totalStr: String? = nil
            if let tracklist = dataModel.selectedTracklist {
                totalStr = "\(tracklist.tracksArray.count)"
            }

            let headerInfo = PlaylistHeaderInfo(
                playlistID: playlist.id,
                title: playlist.title,
                imageUrl: imageUrl,
                largeImageUrl: largeImageUrl,
                durationTime: playlist.duration,
                playlistAuthor: playlist.author,
                total: totalStr)
            return headerInfo
        }
        let noInfoHeader = PlaylistHeaderInfo(
            playlistID: nil,
            title: nil,
            imageUrl: nil,
            largeImageUrl: nil,
            durationTime: nil,
            playlistAuthor: nil,
            total: nil)
        return noInfoHeader
    }
}

