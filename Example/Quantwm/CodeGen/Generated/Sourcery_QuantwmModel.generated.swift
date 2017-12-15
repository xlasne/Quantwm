// Generated using Sourcery 0.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Quantwm
struct QWModel {
    static let rootProperty:QWRootProperty = DataModel.dataModelK
    static let root = DataModelQWModel(path: QWPath(root: rootProperty, chain: []))
}

struct DataModelQWModel
{
    let path:QWPath
    let node:QWMap
    let all: QWMap
    let userId: QWMap
    let selectedPlaylistId: QWMap
    let playlistsCollection: PlaylistsCollectionQWModel
    let trackCollection: TrackCollectionQWModel

    init(path: QWPath) {
        self.path = path
        self.node = path.map
        self.all = path.all().map

        // property: userId
        self.userId = path.appending(DataModel.userIdK).map

        // property: selectedPlaylistId
        self.selectedPlaylistId = path.appending(DataModel.selectedPlaylistIdK).map

        // node: playlistsCollection
        self.playlistsCollection = PlaylistsCollectionQWModel(path: path.appending(DataModel.playlistsCollectionK))

        // node: trackCollection
        self.trackCollection = TrackCollectionQWModel(path: path.appending(DataModel.trackCollectionK))
    }
}

struct PlaylistQWModel
{
    let path:QWPath
    let node:QWMap
    let all: QWMap

    init(path: QWPath) {
        self.path = path
        self.node = path.map
        self.all = path.all().map
    }
}

struct PlaylistsCollectionQWModel
{
    let path:QWPath
    let node:QWMap
    let all: QWMap
    let playlistArray: QWMap
    let playlistDict: QWMap
    let total: QWMap

    init(path: QWPath) {
        self.path = path
        self.node = path.map
        self.all = path.all().map

        // property: playlistArray
        self.playlistArray = path.appending(PlaylistsCollection.playlistArrayK).map

        // property: playlistDict
        self.playlistDict = path.appending(PlaylistsCollection.playlistDictK).map

        // property: total
        self.total = path.appending(PlaylistsCollection.totalK).map
    }
}

struct TrackCollectionQWModel
{
    let path:QWPath
    let node:QWMap
    let all: QWMap
    let trackDict: TracklistQWModel

    init(path: QWPath) {
        self.path = path
        self.node = path.map
        self.all = path.all().map

        // node: trackDict
        self.trackDict = TracklistQWModel(path: path.appending(TrackCollection.trackDictK))
    }
}

struct TracklistQWModel
{
    let path:QWPath
    let node:QWMap
    let all: QWMap
    let finalTracksArray: QWMap

    init(path: QWPath) {
        self.path = path
        self.node = path.map
        self.all = path.all().map

        // property: finalTracksArray
        self.finalTracksArray = path.appending(Tracklist.finalTracksArrayK).map
    }
}

