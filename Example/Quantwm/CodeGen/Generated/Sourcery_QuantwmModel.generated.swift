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
    fileprivate let userId: QWPath
    var userId_Read: QWMap {
        return userId.map
    }
    var userId_Write: QWMap {
        return userId.readWrite(read: false).map
    }
    fileprivate let selectedPlaylistId: QWPath
    var selectedPlaylistId_Read: QWMap {
        return selectedPlaylistId.map
    }
    var selectedPlaylistId_Write: QWMap {
        return selectedPlaylistId.readWrite(read: false).map
    }
    let playlistsCollection: PlaylistsCollectionQWModel
    let trackCollection: TrackCollectionQWModel

    init(path: QWPath) {
        self.path = path
        self.node = path.map

        // property: userId
        self.userId = path.appending(DataModel.userIdK)

        // property: selectedPlaylistId
        self.selectedPlaylistId = path.appending(DataModel.selectedPlaylistIdK)

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


    var all_Write: QWMap {
        return QWMap(pathArray: allPathGetter(read: false))
    }

    var all_Read: QWMap {
        return QWMap(pathArray: allPathGetter(read: true))
    }

    func allPathGetter(read: Bool) -> [QWPath]{
        var pathArray: [QWPath] = []
        pathArray.append(path.readWrite(read: read))
        pathArray.append(path.appending(DataModel.userIdK).readWrite(read: read))
        pathArray.append(path.appending(DataModel.selectedPlaylistIdK).readWrite(read: read))
        pathArray += playlistsCollection.allPathGetter(read: read)
        pathArray += trackCollection.allPathGetter(read: read)
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
    fileprivate let playlistArray: QWPath
    var playlistArray_Read: QWMap {
        return playlistArray.map
    }
    var playlistArray_Write: QWMap {
        return playlistArray.readWrite(read: false).map
    }
    fileprivate let playlistDict: QWPath
    var playlistDict_Read: QWMap {
        return playlistDict.map
    }
    var playlistDict_Write: QWMap {
        return playlistDict.readWrite(read: false).map
    }
    fileprivate let total: QWPath
    var total_Read: QWMap {
        return total.map
    }
    var total_Write: QWMap {
        return total.readWrite(read: false).map
    }

    init(path: QWPath) {
        self.path = path
        self.node = path.map

        // property: playlistArray
        self.playlistArray = path.appending(PlaylistsCollection.playlistArrayK)

        // property: playlistDict
        self.playlistDict = path.appending(PlaylistsCollection.playlistDictK)

        // property: total
        self.total = path.appending(PlaylistsCollection.totalK)
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

    var all_Write: QWMap {
        return QWMap(pathArray: allPathGetter(read: false))
    }

    var all_Read: QWMap {
        return QWMap(pathArray: allPathGetter(read: true))
    }

    func allPathGetter(read: Bool) -> [QWPath]{
        var pathArray: [QWPath] = []
        pathArray.append(path.readWrite(read: read))
        pathArray.append(path.appending(PlaylistsCollection.playlistArrayK).readWrite(read: read))
        pathArray.append(path.appending(PlaylistsCollection.playlistDictK).readWrite(read: read))
        pathArray.append(path.appending(PlaylistsCollection.totalK).readWrite(read: read))
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
    let trackDict: TracklistQWModel

    init(path: QWPath) {
        self.path = path
        self.node = path.map

        // node: trackDict
        self.trackDict = TracklistQWModel(path: path.appending(TrackCollection.trackDictK))
    }

    // MARK: Getter Array


    // node: Getter trackDict
    func trackDictGetter(_ root:TrackCollection) -> [PlaylistID:Tracklist] {
        return root[keyPath:\TrackCollection.trackDict]
    }


    var all_Write: QWMap {
        return QWMap(pathArray: allPathGetter(read: false))
    }

    var all_Read: QWMap {
        return QWMap(pathArray: allPathGetter(read: true))
    }

    func allPathGetter(read: Bool) -> [QWPath]{
        var pathArray: [QWPath] = []
        pathArray.append(path.readWrite(read: read))
        pathArray += trackDict.allPathGetter(read: read)
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
    fileprivate let finalTracksArray: QWPath
    var finalTracksArray_Read: QWMap {
        return finalTracksArray.map
    }
    var finalTracksArray_Write: QWMap {
        return finalTracksArray.readWrite(read: false).map
    }

    init(path: QWPath) {
        self.path = path
        self.node = path.map

        // property: finalTracksArray
        self.finalTracksArray = path.appending(Tracklist.finalTracksArrayK)
    }

    // MARK: Getter Array


    // property: finalTracksArray
    func finalTracksArrayGetter(_ root:Tracklist) -> [Track] {
        return root[keyPath:\Tracklist.finalTracksArray]
    }

    var all_Write: QWMap {
        return QWMap(pathArray: allPathGetter(read: false))
    }

    var all_Read: QWMap {
        return QWMap(pathArray: allPathGetter(read: true))
    }

    func allPathGetter(read: Bool) -> [QWPath]{
        var pathArray: [QWPath] = []
        pathArray.append(path.readWrite(read: read))
        pathArray.append(path.appending(Tracklist.finalTracksArrayK).readWrite(read: read))
        return pathArray
    }

    // MARK: Property Array
    static func getPropertyArray() -> [QWProperty] { return qwPropertyArrayK }
    static let qwPropertyArrayK:[QWProperty] = [
        Tracklist.finalTracksArrayK,  // property
    ]
}

