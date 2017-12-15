// Generated using Sourcery 0.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Quantwm
class QWModel {
    static let rootProperty:QWRootProperty = DataModel.dataModelK
    static let root = DataModelQWModel(path: QWPath(root: rootProperty, chain: []))
}

class DataModelQWModel
{
    init(path: QWPath) {
        self.node = path
    }
    let node:QWPath
    var all: QWPath {
        return node.all()
    }


    var userId: QWPath {
        return node.appending(DataModel.userIdK)
    }
    var selectedPlaylistId: QWPath {
        return node.appending(DataModel.selectedPlaylistIdK)
    }
    var playlistsCollection: PlaylistsCollectionQWModel {
        return PlaylistsCollectionQWModel(path: node.appending(DataModel.playlistsCollectionK))
    }
    var trackCollection: TrackCollectionQWModel {
        return TrackCollectionQWModel(path: node.appending(DataModel.trackCollectionK))
    }
}

class PlaylistQWModel
{
    init(path: QWPath) {
        self.node = path
    }
    let node:QWPath
    var all: QWPath {
        return node.all()
    }


}

class PlaylistsCollectionQWModel
{
    init(path: QWPath) {
        self.node = path
    }
    let node:QWPath
    var all: QWPath {
        return node.all()
    }


    var playlistArray: QWPath {
        return node.appending(PlaylistsCollection.playlistArrayK)
    }
    var playlistDict: QWPath {
        return node.appending(PlaylistsCollection.playlistDictK)
    }
    var total: QWPath {
        return node.appending(PlaylistsCollection.totalK)
    }
}

class TrackCollectionQWModel
{
    init(path: QWPath) {
        self.node = path
    }
    let node:QWPath
    var all: QWPath {
        return node.all()
    }


    var trackDict: TracklistQWModel {
        return TracklistQWModel(path: node.appending(TrackCollection.trackDictK))
    }
}

class TracklistQWModel
{
    init(path: QWPath) {
        self.node = path
    }
    let node:QWPath
    var all: QWPath {
        return node.all()
    }


    var finalTracksArray: QWPath {
        return node.appending(Tracklist.finalTracksArrayK)
    }
}

