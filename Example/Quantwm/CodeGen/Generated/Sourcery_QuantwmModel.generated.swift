// Generated using Sourcery 0.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Quantwm
struct QWModel {
    static let rootProperty:QWRootProperty = DataModel.dataModelK
    static let root = DataModelQWModel(path: QWPath(root: rootProperty))
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


    func allPaths() -> QWMap{
        return QWMap(pathArray: allPathGetter(path: path))
    }

    func allPathGetter(path: QWPath) -> [QWPath]{
        var pathArray: [QWPath] = []
        pathArray.append(path.appending(DataModel.userIdK))
        pathArray.append(path.appending(DataModel.selectedPlaylistIdK))
        pathArray += playlistsCollection.allPathGetter(path: path.appending(DataModel.playlistsCollectionK))
        pathArray += trackCollection.allPathGetter(path: path.appending(DataModel.trackCollectionK))
        return pathArray
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

    func allPaths() -> QWMap{
        return QWMap(pathArray: allPathGetter(path: path))
    }

    func allPathGetter(path: QWPath) -> [QWPath]{
        var pathArray: [QWPath] = []
        pathArray.append(path.appending(PlaylistsCollection.playlistArrayK))
        pathArray.append(path.appending(PlaylistsCollection.playlistDictK))
        pathArray.append(path.appending(PlaylistsCollection.totalK))
        return pathArray
    }

    // MARK: Property Array
    static func getPropertyArray() -> [QWProperty] { return qwPropertyArrayK }
    static let qwPropertyArrayK:[QWProperty] = [
        PlaylistsCollection.playlistArrayK,  // property
        PlaylistsCollection.playlistDictK,  // property
        PlaylistsCollection.totalK,  // property
    ]
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

    // MARK: Getter Array


    // node: Getter trackDict
    func trackDictGetter(_ root:TrackCollection) -> [PlaylistID:Tracklist] {
        return root[keyPath:\TrackCollection.trackDict]
    }


    func allPaths() -> QWMap{
        return QWMap(pathArray: allPathGetter(path: path))
    }

    func allPathGetter(path: QWPath) -> [QWPath]{
        var pathArray: [QWPath] = []
        pathArray += trackDict.allPathGetter(path: path.appending(TrackCollection.trackDictK))
        return pathArray
    }

    // MARK: Property Array
    static func getPropertyArray() -> [QWProperty] { return qwPropertyArrayK }
    static let qwPropertyArrayK:[QWProperty] = [
        TrackCollection.trackDictK,   // node
    ]
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

    // MARK: Getter Array


    // property: finalTracksArray
    func finalTracksArrayGetter(_ root:Tracklist) -> [Track] {
        return root[keyPath:\Tracklist.finalTracksArray]
    }

    func allPaths() -> QWMap{
        return QWMap(pathArray: allPathGetter(path: path))
    }

    func allPathGetter(path: QWPath) -> [QWPath]{
        var pathArray: [QWPath] = []
        pathArray.append(path.appending(Tracklist.finalTracksArrayK))
        return pathArray
    }

    // MARK: Property Array
    static func getPropertyArray() -> [QWProperty] { return qwPropertyArrayK }
    static let qwPropertyArrayK:[QWProperty] = [
        Tracklist.finalTracksArrayK,  // property
    ]
}

