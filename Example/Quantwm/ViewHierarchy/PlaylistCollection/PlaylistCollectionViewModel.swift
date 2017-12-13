//
//  PlaylistsCollectionViewModel.swift
//  deezer
//
//  Created by Xavier on 02/12/2017.
//  Copyright © 2017 XL Software Solutions. => MIT License
//

import UIKit
import RxSwift
import Quantwm

class PlaylistsCollectionViewModel: GenericViewModel<DataModel>
{


    // User Actions

    // User Selection
    func selectNextUser() {
        updateActionAndRefresh {
            dataModel.userId += 1
        }
    }

    func selectPreviousUser() {
        updateActionAndRefresh {
            if dataModel.userId > 1 {
                dataModel.userId -= 1
            }
        }
    }

    func selectPlaylist(indexPath: IndexPath?) {
        updateActionAndRefresh {
            var selectedPlaylistId:PlaylistID? = nil
            if let indexPath = indexPath {
                selectedPlaylistId = playlistIDForIndexPath(indexPath: indexPath)
            }
            dataModel.selectedPlaylistId = selectedPlaylistId
        }
    }

    // UserID
    static let titleMap = DataModel.userIdMap +
        PlaylistsCollection.totalMap +
        PlaylistsCollection.playlistArrayMap

    func getTitle() -> String {
        var title = "\(dataModel.userId)"
        let total = dataModel.playlistsCollection.total
        if total != -1 {
            title += " \(dataModel.playlistsCollection.playlistsCount)/\(total)"
        }
        return title
    }

    // Data Source for Playlist Collection

    // We are monitoring the playlist informations, not the tracks
    // Playlist informations are not editable
    // Hence, this map detects all the changes
    static let playlistCollectionDataSourceMap =
        PlaylistsCollection.playlistArrayMap
        + PlaylistsCollection.playlistDictMap

    // This map gives access to the 3 functions below for reading the model only

    func playlistCount() -> Int {
        return dataModel.playlistsCollection.playlistsCount
    }

    func isPlaylistExistingFor(indexPath: IndexPath) -> Bool {
        if indexPath.section != 0 {
            return false
        }
        let row = indexPath.row
        return (dataModel.playlistsCollection.playlist(rowIndex: row) != nil)
    }

    func playlistIDForIndexPath(indexPath: IndexPath) -> PlaylistID? {
        let row = indexPath.row
        return dataModel.playlistsCollection.playlist(rowIndex: row)?.id
    }

    func playlistCoverInfoForIndexPath(indexPath: IndexPath) -> PlaylistCoverInfo? {
        let row = indexPath.row
        if let playlist = dataModel.playlistsCollection.playlist(rowIndex: row) {
            var imageUrl:URL? = nil
            if let urlStr = playlist.picture_medium {
                imageUrl = URL(string: urlStr)
            }
            let coverInfo = PlaylistCoverInfo(playlistID: playlist.id,
                                              title: playlist.title,
                                              imageUrl: imageUrl)
            return coverInfo
        }
        return nil
    }
}
