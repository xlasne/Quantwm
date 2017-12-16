// Generated using Sourcery 0.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Quantwm
struct QWModel {
    static let rootProperty:QWRootProperty = DataModel.dataModelK
    static let root = DataModelQWModel(path: QWPath(root: rootProperty))
}

struct DataModelQWModel: QWModelProperty
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

    // MARK: Getter Array


    // property: userId
    func userIdGetter(_ root:DataModel) -> UserID {
        return root[keyPath:\DataModel.userId]
    }

    // property: selectedPlaylistId
    func selectedPlaylistIdGetter(_ root:DataModel) -> PlaylistID? {
        return root[keyPath:\DataModel.selectedPlaylistId]
    }

    // node: Getter playlistsCollection
    func playlistsCollectionGetter(_ root:DataModel) -> PlaylistsCollection {
        return root[keyPath:\DataModel.playlistsCollection]
    }


    // node: Getter trackCollection
    func trackCollectionGetter(_ root:DataModel) -> TrackCollection {
        return root[keyPath:\DataModel.trackCollection]
    }



    // MARK: Property Array
    static func getPropertyArray() -> [QWProperty] { return qwPropertyArrayK }
    static let qwPropertyArrayK:[QWProperty] = [
        DataModel.userIdK,  // property
        DataModel.selectedPlaylistIdK,  // property
        DataModel.playlistsCollectionK,   // node
        DataModel.trackCollectionK,   // node
    ]
}

struct PlaylistQWModel: QWModelProperty
{
    let path:QWPath
    let node:QWMap
    let all: QWMap

    init(path: QWPath) {
        self.path = path
        self.node = path.map
        self.all = path.all().map
    }

    // MARK: Getter Array



    // MARK: Property Array
    static func getPropertyArray() -> [QWProperty] { return qwPropertyArrayK }
    static let qwPropertyArrayK:[QWProperty] = [
    ]
}

struct PlaylistsCollectionQWModel: QWModelProperty
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

    // MARK: Getter Array


    // property: playlistArray
    func playlistArrayGetter(_ root:PlaylistsCollection) -> [PlaylistID] {
        return root[keyPath:\PlaylistsCollection.playlistArray]
    }

    // property: playlistDict
    func playlistDictGetter(_ root:PlaylistsCollection) -> [PlaylistID:Playlist] {
        return root[keyPath:\PlaylistsCollection.playlistDict]
    }

    // property: total
    func totalGetter(_ root:PlaylistsCollection) -> Int {
        return root[keyPath:\PlaylistsCollection.total]
    }


    // MARK: Property Array
    static func getPropertyArray() -> [QWProperty] { return qwPropertyArrayK }
    static let qwPropertyArrayK:[QWProperty] = [
        PlaylistsCollection.playlistArrayK,  // property
        PlaylistsCollection.playlistDictK,  // property
        PlaylistsCollection.totalK,  // property
    ]
}

struct TrackCollectionQWModel: QWModelProperty
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

    // MARK: Getter Array


    // node: Getter trackDict
    func trackDictGetter(_ root:TrackCollection) -> [PlaylistID:Tracklist] {
        return root[keyPath:\TrackCollection.trackDict]
    }



    // MARK: Property Array
    static func getPropertyArray() -> [QWProperty] { return qwPropertyArrayK }
    static let qwPropertyArrayK:[QWProperty] = [
        TrackCollection.trackDictK,   // node
    ]
}

struct TracklistQWModel: QWModelProperty
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

    // MARK: Getter Array


    // property: finalTracksArray
    func finalTracksArrayGetter(_ root:Tracklist) -> [Track] {
        return root[keyPath:\Tracklist.finalTracksArray]
    }


    // MARK: Property Array
    static func getPropertyArray() -> [QWProperty] { return qwPropertyArrayK }
    static let qwPropertyArrayK:[QWProperty] = [
        Tracklist.finalTracksArrayK,  // property
    ]
}

