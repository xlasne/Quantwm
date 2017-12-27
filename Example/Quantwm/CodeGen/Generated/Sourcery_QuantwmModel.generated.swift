// Generated using Sourcery 0.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Quantwm
struct QWModel {
    static let rootProperty:QWRootProperty = DataModel.dataModelK
    static var root = DataModelQWModel(path: QWPath(root: rootProperty))
}

class DataModelQWModel
{
    let path:QWPath
    fileprivate let node:QWMap
    var readDependency: QWMap
    fileprivate let userId: QWPath
    var userId_Read: QWMap {
        return userId.map
        + self.readDependency
    }
    var userId_Write: QWMap {
        return userId.readWrite(read: false).map
        + self.readDependency
    }

    fileprivate let selectedPlaylistId: QWPath
    var selectedPlaylistId_Read: QWMap {
        return selectedPlaylistId.map
        + self.readDependency
    }
    var selectedPlaylistId_Write: QWMap {
        return selectedPlaylistId.readWrite(read: false).map
        + self.readDependency
    }

    var playlistsCollection: PlaylistsCollectionQWModel
    var playlistsCollection_allRead: QWMap {
        return QWMap(pathArray: playlistsCollection.allPathGetter(read: true))
            + self.readDependency
    }
    var playlistsCollection_Read: QWMap {
        return playlistsCollection.path.map
            + self.readDependency
    }
    var playlistsCollection_allWrite: QWMap {
        return QWMap(pathArray: playlistsCollection.allPathGetter(read: false))
            + self.readDependency
    }
    var playlistsCollection_Write: QWMap {
        return playlistsCollection.path.readWrite(read: false).map
            + self.readDependency
    }

    var trackListCollection: TrackListCollectionQWModel
    var trackListCollection_allRead: QWMap {
        return QWMap(pathArray: trackListCollection.allPathGetter(read: true))
            + self.readDependency
    }
    var trackListCollection_Read: QWMap {
        return trackListCollection.path.map
            + self.readDependency
    }
    var trackListCollection_allWrite: QWMap {
        return QWMap(pathArray: trackListCollection.allPathGetter(read: false))
            + self.readDependency
    }
    var trackListCollection_Write: QWMap {
        return trackListCollection.path.readWrite(read: false).map
            + self.readDependency
    }


    init(path: QWPath, readDependency: QWMap? = nil) {
        self.path = path
        self.node = path.map
        self.readDependency = readDependency ?? QWMap(pathArray:[])


        // property: userId
        self.userId = path.appending(DataModel.userIdK)

        // property: selectedPlaylistId
        self.selectedPlaylistId = path.appending(DataModel.selectedPlaylistIdK)

        // node: playlistsCollection
        self.playlistsCollection = PlaylistsCollectionQWModel(path: path.appending(DataModel.playlistsCollectionK)
            , readDependency: self.readDependency)

        // node: trackListCollection
        self.trackListCollection = TrackListCollectionQWModel(path: path.appending(DataModel.trackListCollectionK)
            , readDependency: self.readDependency)
    }

    // MARK: Computed Variables Array


    lazy fileprivate var selectedPlaylist: QWPath = path.appending(DataModel.selectedPlaylistK)
    var selectedPlaylist_Read: QWMap {
        return selectedPlaylist.map
            + DataModel.selectedPlaylistDependencies
    }

    // node: Computed selectedTracklist
    var selectedTracklist:TracklistQWModel {
        return TracklistQWModel(path: path.appending(DataModel.selectedTracklistK), readDependency:DataModel.selectedTracklistDependencies)
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


    // node: Getter trackListCollection
    func trackListCollectionGetter(_ root:DataModel) -> TrackListCollection {
        return root[keyPath:\DataModel.trackListCollection]
    }


    // property: selectedPlaylist
    func selectedPlaylistGetter(_ root:DataModel) -> Playlist? {
        return root[keyPath:\DataModel.selectedPlaylist]
    }

    // node: Getter selectedTracklist
    func selectedTracklistGetter(_ root:DataModel) -> Tracklist? {
        return root[keyPath:\DataModel.selectedTracklist]
    }



    var all_Write: QWMap {
        return QWMap(pathArray: allPathGetter(read: false))
            + self.readDependency
    }

    var all_Read: QWMap {
        return QWMap(pathArray: allPathGetter(read: true))
            + self.readDependency
    }

    fileprivate func allPathGetter(read: Bool) -> [QWPath]{
        var pathArray: [QWPath] = []
        pathArray.append(path.readWrite(read: read))
        pathArray.append(path.appending(DataModel.userIdK).readWrite(read: read))
        pathArray.append(path.appending(DataModel.selectedPlaylistIdK).readWrite(read: read))
        pathArray += playlistsCollection.allPathGetter(read: read)
        pathArray += trackListCollection.allPathGetter(read: read)
        pathArray.append(path.appending(DataModel.selectedPlaylistK).readWrite(read: read))
        pathArray += selectedTracklist.allPathGetter(read: read)
        return pathArray
    }

    // MARK: Property Array
    static func getPropertyArray() -> [QWProperty] { return qwPropertyArrayK }
    static let qwPropertyArrayK:[QWProperty] = [
        DataModel.userIdK,  // property
        DataModel.selectedPlaylistIdK,  // property
        DataModel.playlistsCollectionK,   // node
        DataModel.trackListCollectionK,   // node
        DataModel.selectedPlaylistK,  // property
        DataModel.selectedTracklistK,   // node
    ]
}

class PlaylistsCollectionQWModel
{
    let path:QWPath
    fileprivate let node:QWMap
    var readDependency: QWMap
    fileprivate let playlistArray: QWPath
    var playlistArray_Read: QWMap {
        return playlistArray.map
        + self.readDependency
    }
    var playlistArray_Write: QWMap {
        return playlistArray.readWrite(read: false).map
        + self.readDependency
    }

    fileprivate let total: QWPath
    var total_Read: QWMap {
        return total.map
        + self.readDependency
    }
    var total_Write: QWMap {
        return total.readWrite(read: false).map
        + self.readDependency
    }


    init(path: QWPath, readDependency: QWMap? = nil) {
        self.path = path
        self.node = path.map
        self.readDependency = readDependency ?? QWMap(pathArray:[])


        // property: playlistArray
        self.playlistArray = path.appending(PlaylistsCollection.playlistArrayK)

        // property: total
        self.total = path.appending(PlaylistsCollection.totalK)
    }

    // MARK: Computed Variables Array





    // MARK: Getter Array


    // property: playlistArray
    func playlistArrayGetter(_ root:PlaylistsCollection) -> [Playlist] {
        return root[keyPath:\PlaylistsCollection.playlistArray]
    }

    // property: total
    func totalGetter(_ root:PlaylistsCollection) -> Int {
        return root[keyPath:\PlaylistsCollection.total]
    }


    var all_Write: QWMap {
        return QWMap(pathArray: allPathGetter(read: false))
            + self.readDependency
    }

    var all_Read: QWMap {
        return QWMap(pathArray: allPathGetter(read: true))
            + self.readDependency
    }

    fileprivate func allPathGetter(read: Bool) -> [QWPath]{
        var pathArray: [QWPath] = []
        pathArray.append(path.readWrite(read: read))
        pathArray.append(path.appending(PlaylistsCollection.playlistArrayK).readWrite(read: read))
        pathArray.append(path.appending(PlaylistsCollection.totalK).readWrite(read: read))
        return pathArray
    }

    // MARK: Property Array
    static func getPropertyArray() -> [QWProperty] { return qwPropertyArrayK }
    static let qwPropertyArrayK:[QWProperty] = [
        PlaylistsCollection.playlistArrayK,  // property
        PlaylistsCollection.totalK,  // property
    ]
}

class TrackListCollectionQWModel
{
    let path:QWPath
    fileprivate let node:QWMap
    var readDependency: QWMap
    var trackDict: TracklistQWModel
    var trackDict_allRead: QWMap {
        return QWMap(pathArray: trackDict.allPathGetter(read: true))
            + self.readDependency
    }
    var trackDict_Read: QWMap {
        return trackDict.path.map
            + self.readDependency
    }
    var trackDict_allWrite: QWMap {
        return QWMap(pathArray: trackDict.allPathGetter(read: false))
            + self.readDependency
    }
    var trackDict_Write: QWMap {
        return trackDict.path.readWrite(read: false).map
            + self.readDependency
    }


    init(path: QWPath, readDependency: QWMap? = nil) {
        self.path = path
        self.node = path.map
        self.readDependency = readDependency ?? QWMap(pathArray:[])


        // node: trackDict
        self.trackDict = TracklistQWModel(path: path.appending(TrackListCollection.trackDictK)
            , readDependency: self.readDependency)
    }

    // MARK: Computed Variables Array



    // MARK: Getter Array


    // node: Getter trackDict
    func trackDictGetter(_ root:TrackListCollection) -> [PlaylistID:Tracklist] {
        return root[keyPath:\TrackListCollection.trackDict]
    }



    var all_Write: QWMap {
        return QWMap(pathArray: allPathGetter(read: false))
            + self.readDependency
    }

    var all_Read: QWMap {
        return QWMap(pathArray: allPathGetter(read: true))
            + self.readDependency
    }

    fileprivate func allPathGetter(read: Bool) -> [QWPath]{
        var pathArray: [QWPath] = []
        pathArray.append(path.readWrite(read: read))
        pathArray += trackDict.allPathGetter(read: read)
        return pathArray
    }

    // MARK: Property Array
    static func getPropertyArray() -> [QWProperty] { return qwPropertyArrayK }
    static let qwPropertyArrayK:[QWProperty] = [
        TrackListCollection.trackDictK,   // node
    ]
}

class TracklistQWModel
{
    let path:QWPath
    fileprivate let node:QWMap
    var readDependency: QWMap
    fileprivate let finalTracksArray: QWPath
    var finalTracksArray_Read: QWMap {
        return finalTracksArray.map
        + self.readDependency
    }
    var finalTracksArray_Write: QWMap {
        return finalTracksArray.readWrite(read: false).map
        + self.readDependency
    }


    init(path: QWPath, readDependency: QWMap? = nil) {
        self.path = path
        self.node = path.map
        self.readDependency = readDependency ?? QWMap(pathArray:[])


        // property: finalTracksArray
        self.finalTracksArray = path.appending(Tracklist.finalTracksArrayK)
    }

    // MARK: Computed Variables Array




    // MARK: Getter Array


    // property: finalTracksArray
    func finalTracksArrayGetter(_ root:Tracklist) -> [Track] {
        return root[keyPath:\Tracklist.finalTracksArray]
    }


    var all_Write: QWMap {
        return QWMap(pathArray: allPathGetter(read: false))
            + self.readDependency
    }

    var all_Read: QWMap {
        return QWMap(pathArray: allPathGetter(read: true))
            + self.readDependency
    }

    fileprivate func allPathGetter(read: Bool) -> [QWPath]{
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

