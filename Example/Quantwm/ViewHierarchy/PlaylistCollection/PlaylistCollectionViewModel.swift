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
    let playlistCollectionModel: PlaylistsCollectionQWModel

    init(dataModel: DataModel, owner: String,
                  playlistCollectionModel: PlaylistsCollectionQWModel) {
        self.playlistCollectionModel = playlistCollectionModel
        super.init(dataModel: dataModel, owner: owner)
    }

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

    // MARK: - Get Title
    var mapForTitle: QWMap {
        return QWModel.root.userId +
            playlistCollectionModel.total +
            PlaylistsCollection.playlistsCountMap(root: playlistCollectionModel)
    }


    func getTitle() -> String {
        var title = "\(dataModel.userId)"
        let total = dataModel.playlistsCollection.total
        if total != -1 {
            title += " \(dataModel.playlistsCollection.playlistsCount)/\(total)"
        }
        return title
    }

    // MARK: - Data Source for Playlist Collection

    // Normally, I would write this:
    // static let playlistCollectionDataSourceMap = QWModel.root.playlistsCollection.all
    // But to show example for more complex situation, let's do as if there was
    // multiple playlistsCollection in the model
    var mapForPlaylistCollectionDataSource: QWMap {
        return PlaylistsCollection.playlistsCountMap(root: playlistCollectionModel) +
            PlaylistsCollection.playlistForIndexMap(root: playlistCollectionModel)
    }

    // This map gives access to the 3 functions below for reading the model only

    func playlistCount() -> Int {
        return dataModel.playlistsCollection.playlistsCount
    }

    func isPlaylistExistingFor(indexPath: IndexPath) -> Bool {
        if indexPath.section != 0 {
            return false
        }
        let row = indexPath.row
        return (dataModel.playlistsCollection.playlistForIndex(rowIndex: row) != nil)
    }

    func playlistIDForIndexPath(indexPath: IndexPath) -> PlaylistID? {
        let row = indexPath.row
        return dataModel.playlistsCollection.playlistForIndex(rowIndex: row)?.id
    }

    func playlistCoverInfoForIndexPath(indexPath: IndexPath) -> PlaylistCoverInfo? {
        let row = indexPath.row
        if let playlist = dataModel.playlistsCollection.playlistForIndex(rowIndex: row) {
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
