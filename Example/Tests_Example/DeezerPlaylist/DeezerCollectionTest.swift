//
//  DeezerCollectionTest.swift
//  deezerTests
//
//  Created by Xavier on 02/12/2017.
//  Copyright © 2017 XL Software Solutions. => MIT License
//

import XCTest

@testable import Quantwm_Example

class DeezerCollectionTests: XCTestCase {
    
    var dataModel: DataModel?
    var networkStub: NetworkStub = NetworkStub()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        dataModel = DataModel(networkMgr: networkStub)
        
    }
    
    func importPlaylistChunk(index: Int, chunk: Int) {
    }
    
    func checkPlaylist(importIndex: Int) {
        let playlist = dataModel!.playlistsCollection.playlist(playlistId: 252588531)!
        let checkPlaylist = CheckPlaylist(playlist: playlist)
        checkPlaylist.check(importIndex: importIndex)
    }
    
    func testExample() {
        XCTAssert(dataModel!.playlistsCollection.updateIndex == nil,"Invalid update Index")
        XCTAssert(dataModel!.playlistsCollection.updatedPlaylistArray == [],"Invalid update array")
        DeezerPlaylistStub.importPlaylistChunk(dataModel: dataModel!, index: 2, chunk: 1)
        XCTAssert(dataModel!.playlistsCollection.updatedPlaylistArray.count == 25,"Invalid update array")
        DeezerPlaylistStub.importPlaylistChunk(dataModel: dataModel!, index: 2, chunk: 2)
        DeezerPlaylistStub.importPlaylistChunk(dataModel: dataModel!, index: 2, chunk: 3)
        DeezerPlaylistStub.importPlaylistChunk(dataModel: dataModel!, index: 2, chunk: 4)
        DeezerPlaylistStub.importPlaylistChunk(dataModel: dataModel!, index: 2, chunk: 5)
        XCTAssert(dataModel!.playlistsCollection.updateIndex == 2,"Invalid update Index")
        checkPlaylist(importIndex: 2)
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
}

