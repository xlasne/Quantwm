//
//  PlaylistCollectionViewModelTest.swift
//  deezerTests
//
//  Created by Xavier on 02/12/2017.
//  Copyright © 2017 XL Software Solutions. => MIT License
//

import XCTest
import Quantwm

@testable import Quantwm_Example

class PlaylistCollectionViewModelTest: XCTestCase {
    
    var dataModel: DataModel?
    var networkStub: NetworkStub = NetworkStub()
    var viewModel: PlaylistsCollectionViewModel?
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        dataModel = DataModel(networkMgr: networkStub as DeezerAPI)
        viewModel = PlaylistsCollectionViewModel(dataModel: dataModel!, owner: "TestVM",
            playlistCollectionModel:QWModel.root.playlistsCollection)
    }

    func testPartialImport() {
        DeezerPlaylistStub.importPlaylistChunk(dataModel: dataModel!, index: 2, chunk: 1)
        XCTAssert(viewModel!.playlistCount() == 25)
        XCTAssert(viewModel!.playlistIDForIndexPath(indexPath: IndexPath(row: 3, section: 0)) == 252588531)

        XCTAssert(viewModel!.isPlaylistExistingFor(indexPath:IndexPath(row: 0, section: 0)) == true)
        XCTAssert(viewModel!.isPlaylistExistingFor(indexPath:IndexPath(row: 24, section: 0)) == true)
        XCTAssert(viewModel!.isPlaylistExistingFor(indexPath:IndexPath(row: 25, section: 0)) == false)
        XCTAssert(viewModel!.isPlaylistExistingFor(indexPath:IndexPath(row: 25, section: 1)) == false)

        let playlistCover = viewModel?.playlistCoverInfoForIndexPath(indexPath: IndexPath(row: 3, section: 0))
        XCTAssert(playlistCover!.playlistID == 252588531)
        XCTAssert(playlistCover!.title == "---- A découvrir")
        XCTAssert(playlistCover!.imageUrl!.absoluteString == "https://e-cdns-images.dzcdn.net/images/playlist/8961c80799a4d93cba20abf3b1aa0648/250x250-000000-80-0-0.jpg")
    }

    func testWithRegistration() {

        let playlistUpdatedREG: QWRegistration = QWRegistration(
            smartWithReadMap: viewModel!.mapForPlaylistCollectionDataSource,
            name: "PlaylistsCollectionViewController.playlistsCollectionUpdated")
        dataModel!.qwMediator.updateActionAndRefresh(owner: self) {
            self.viewModel!.registerObserver(
                registration: playlistUpdatedREG,
                target: self,
                selector: #selector(PlaylistCollectionViewModelTest.followUpTestWithRegistration)
            )
            DeezerPlaylistStub.importPlaylistChunk(dataModel: dataModel!, index: 2, chunk: 1)
            DeezerPlaylistStub.importPlaylistChunk(dataModel: dataModel!, index: 2, chunk: 2)
            DeezerPlaylistStub.importPlaylistChunk(dataModel: dataModel!, index: 2, chunk: 3)
            DeezerPlaylistStub.importPlaylistChunk(dataModel: dataModel!, index: 2, chunk: 4)
            DeezerPlaylistStub.importPlaylistChunk(dataModel: dataModel!, index: 2, chunk: 5)
        }
    }

    @objc func followUpTestWithRegistration() {
        XCTAssert(viewModel!.playlistCount() == 110)
        XCTAssert(viewModel!.playlistIDForIndexPath(indexPath: IndexPath(row: 3, section: 0)) == 252588531)

        XCTAssert(viewModel!.isPlaylistExistingFor(indexPath:IndexPath(row: 0, section: 0)) == true)
        XCTAssert(viewModel!.isPlaylistExistingFor(indexPath:IndexPath(row: 109, section: 0)) == true)
        XCTAssert(viewModel!.isPlaylistExistingFor(indexPath:IndexPath(row: 110, section: 0)) == false)
        XCTAssert(viewModel!.isPlaylistExistingFor(indexPath:IndexPath(row: 0, section: 1)) == false)

        let playlistCover = viewModel?.playlistCoverInfoForIndexPath(indexPath: IndexPath(row: 3, section: 0))
        XCTAssert(playlistCover!.playlistID == 252588531)
        XCTAssert(playlistCover!.title == "---- A découvrir")
        XCTAssert(playlistCover!.imageUrl!.absoluteString == "https://e-cdns-images.dzcdn.net/images/playlist/8961c80799a4d93cba20abf3b1aa0648/250x250-000000-80-0-0.jpg")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
}

