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

    // node: Getter Self
    func nodeGetter() -> (QWRoot) -> [QWNode] { return  path.generateNodeGetter() }


    // property: userId
    func userIdGetter() -> (QWRoot) -> [UserID] { return path.generatePropertyGetter(property: DataModel.userIdK) }

    // property: selectedPlaylistId
    func selectedPlaylistIdGetter() -> (QWRoot) -> [PlaylistID?] { return path.generatePropertyGetter(property: DataModel.selectedPlaylistIdK) }

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

    // node: Getter Self
    func nodeGetter() -> (QWRoot) -> [QWNode] { return  path.generateNodeGetter() }


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

    // node: Getter Self
    func nodeGetter() -> (QWRoot) -> [QWNode] { return  path.generateNodeGetter() }


    // property: playlistArray
    func playlistArrayGetter() -> (QWRoot) -> [[PlaylistID]] { return path.generatePropertyGetter(property: PlaylistsCollection.playlistArrayK) }

    // property: playlistDict
    func playlistDictGetter() -> (QWRoot) -> [[PlaylistID:Playlist]] { return path.generatePropertyGetter(property: PlaylistsCollection.playlistDictK) }

    // property: total
    func totalGetter() -> (QWRoot) -> [Int] { return path.generatePropertyGetter(property: PlaylistsCollection.totalK) }

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

    // node: Getter Self
    func nodeGetter() -> (QWRoot) -> [QWNode] { return  path.generateNodeGetter() }


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

    // node: Getter Self
    func nodeGetter() -> (QWRoot) -> [QWNode] { return  path.generateNodeGetter() }


    // property: finalTracksArray
    func finalTracksArrayGetter() -> (QWRoot) -> [[Track]] { return path.generatePropertyGetter(property: Tracklist.finalTracksArrayK) }

    // MARK: Property Array
    static func getPropertyArray() -> [QWProperty] { return qwPropertyArrayK }
    static let qwPropertyArrayK:[QWProperty] = [
        Tracklist.finalTracksArrayK,  // property
    ]
}

