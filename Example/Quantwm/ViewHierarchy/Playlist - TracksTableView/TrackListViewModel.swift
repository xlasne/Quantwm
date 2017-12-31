//
//  TrackListViewModel.swift
//  deezer
//
//  Created by Xavier on 03/12/2017.
//  Copyright © 2017 XL Software Solutions. => MIT License
//

import UIKit
import Quantwm

class TrackListViewModel: QWViewModel<DataModel>
{
    let trackListCollectionModel: TrackListCollectionQWModel

    init(dataModel: DataModel, owner: String,
         trackListCollectionModel: TrackListCollectionQWModel) {
        self.trackListCollectionModel = trackListCollectionModel
        super.init(dataModel: dataModel, owner: owner)
    }

    // Datasource for tracks table view
    var mapForTracksTableDataSource: QWMap {
        return trackListCollectionModel.trackDict.all_Read
        + QWModel.root.selectedPlaylistId_Read
    }

    var trackArray: [Track] {
        let selectedPlaylistId = QWModel.root.selectedPlaylistIdGetter(dataModel)
        if let selectedPlaylistId = selectedPlaylistId {
            let trackDict = QWModel.root.trackListCollectionGetter(dataModel).trackDict
            return trackDict[selectedPlaylistId]?.tracksArray ?? []
        } else {
            return []
        }
    }

    var nbTracks: Int {
        return trackArray.count
    }

    func trackInfo(indexPath: IndexPath) -> TrackInfo {
        let rowIndex = indexPath.row
        if (0 <= rowIndex) && (rowIndex < trackArray.count) {
            let track = trackArray[rowIndex]
            let trackInfo = TrackInfo(trackLabel: track.title ?? "No title",
                                      artistLabel: track.artistName  ?? "No artist",
                                      duration: track.formattedDuration,
                                      evenRow: (rowIndex % 2 == 0))
            return trackInfo
        }
        return TrackListViewModel.errorTrackInfo(indexPath: indexPath)
    }

    static func errorTrackInfo(indexPath: IndexPath) -> TrackInfo {
        let rowIndex = indexPath.row
        return TrackInfo(trackLabel:  "Error",
                         artistLabel:  "Error",
                         duration: "00:00:00",
                         evenRow: (rowIndex % 2 == 0))
    }

}
