// Generated using Sourcery 0.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Quantwm
struct QWModel {
    static let rootProperty:QWRootProperty = DataModel.dataModelK
    static let root = DataModelQWModel(path: QWPath(root: rootProperty, chain: []))
}

struct DataModelQWModel
{
    let node:QWPath
    let all: QWPath
    let userId: QWPath
    let selectedPlaylistId: QWPath
    let playlistsCollection: PlaylistsCollectionQWModel
    let trackCollection: TrackCollectionQWModel

    init(path: QWPath) {
        self.node = path
        self.all = path.all()

        // property: userId
        self.userId = node.appending(DataModel.userIdK)

        // property: selectedPlaylistId
        self.selectedPlaylistId = node.appending(DataModel.selectedPlaylistIdK)

        // node: playlistsCollection
        self.playlistsCollection = PlaylistsCollectionQWModel(path: node.appending(DataModel.playlistsCollectionK))

        // node: trackCollection
        self.trackCollection = TrackCollectionQWModel(path: node.appending(DataModel.trackCollectionK))
    }


}

struct PlaylistQWModel
{
    let node:QWPath
    let all: QWPath

    init(path: QWPath) {
        self.node = path
        self.all = path.all()
    }


}

struct PlaylistsCollectionQWModel
{
    let node:QWPath
    let all: QWPath
    let playlistArray: QWPath
    let playlistDict: QWPath
    let total: QWPath

    init(path: QWPath) {
        self.node = path
        self.all = path.all()

        // property: playlistArray
        self.playlistArray = node.appending(PlaylistsCollection.playlistArrayK)

        // property: playlistDict
        self.playlistDict = node.appending(PlaylistsCollection.playlistDictK)

        // property: total
        self.total = node.appending(PlaylistsCollection.totalK)
    }


}

struct TrackCollectionQWModel
{
    let node:QWPath
    let all: QWPath
    let trackDict: TracklistQWModel

    init(path: QWPath) {
        self.node = path
        self.all = path.all()

        // node: trackDict
        self.trackDict = TracklistQWModel(path: node.appending(TrackCollection.trackDictK))
    }


}

struct TracklistQWModel
{
    let node:QWPath
    let all: QWPath
    let finalTracksArray: QWPath

    init(path: QWPath) {
        self.node = path
        self.all = path.all()

        // property: finalTracksArray
        self.finalTracksArray = node.appending(Tracklist.finalTracksArrayK)
    }


}

