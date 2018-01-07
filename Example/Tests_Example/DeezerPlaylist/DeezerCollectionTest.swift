//
//  DeezerCollectionTest.swift
//  deezerTests
//
//  Created by Xavier Lasne on 02/12/2017.
//  Copyright  MIT License
//

import XCTest

@testable import Quantwm_Example

class DeezerCollectionTests: XCTestCase {

    let qwMediator = Mediator()
    var dataModel: DataModel!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        dataModel = DataModel(mediator: qwMediator)
        
    }
    
    func importPlaylistChunk(index: Int, chunk: Int) {
    }
    
    func checkPlaylist(importIndex: Int) {
        let playlist = dataModel.playlistsCollection.playlist(playlistId: 252588531)!
        let checkPlaylist = CheckPlaylist(playlist: playlist)
        checkPlaylist.check(importIndex: importIndex)
    }
    
    func testExample() {
        XCTAssert(dataModel.playlistsCollection.updateIndex == nil,"Invalid update Index")
        XCTAssert(dataModel.playlistsCollection.playlistArray.count == 0,"Invalid update array")
        DeezerPlaylistStub.importPlaylistChunk(dataModel: dataModel, index: 2, chunk: 1)
        XCTAssert(dataModel.playlistsCollection.playlistArray.count == 25,"Invalid update array")
        DeezerPlaylistStub.importPlaylistChunk(dataModel: dataModel, index: 2, chunk: 2)
        DeezerPlaylistStub.importPlaylistChunk(dataModel: dataModel, index: 2, chunk: 3)
        DeezerPlaylistStub.importPlaylistChunk(dataModel: dataModel, index: 2, chunk: 4)
        DeezerPlaylistStub.importPlaylistChunk(dataModel: dataModel, index: 2, chunk: 5)
        XCTAssert(dataModel.playlistsCollection.updateIndex == 2,"Invalid update Index")
        checkPlaylist(importIndex: 2)
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
}

