//
//  Tracklist.swift
//  Quantwm_Example
//
//  Created by Xavier on 20/12/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import Quantwm

class Tracklist: QWNode_S, Codable {

    private var _finalImportIndex: Int? = nil

    // sourcery: property
    private var _finalTracksArray: [Track] = []

    private var _inProgressImportIndex: Int? = nil
    private var _inProgressTracksArray: [Track] = []

    func addTracks(importIndex: Int, tracksArray: [Track], lastChunk: Bool) {
        if importIndex != _inProgressImportIndex {
            _inProgressImportIndex = importIndex
            _inProgressTracksArray = []
        }
        _inProgressTracksArray += tracksArray
        if _finalImportIndex == nil {
            // If nothing present, start displaying in progress download.
            finalTracksArray = _inProgressTracksArray
        }
        if lastChunk {
            _finalImportIndex = _inProgressImportIndex
            finalTracksArray = _inProgressTracksArray
            _inProgressImportIndex = importIndex
            _inProgressTracksArray = []
        }
    }

    var tracksArray: [Track] {
        return finalTracksArray
    }

    // sourcery:inline:Tracklist.QuantwmDeclarationInline

    // MARK: - Sourcery

    // QWNode protocol
    func getQWCounter() -> QWCounter {
      return qwCounter
    }
    let qwCounter = QWCounter(name:"Tracklist")
    func getPropertyArray() -> [QWProperty] {
        return TracklistQWModel.getPropertyArray()
    }


    // Quantwm Property: finalTracksArray
    static let finalTracksArrayK = QWPropProperty(
        propertyKeypath: \Tracklist.finalTracksArray,
        description: "_finalTracksArray")
    var finalTracksArray : [Track] {
      get {
        self.qwCounter.read(Tracklist.finalTracksArrayK)
        return _finalTracksArray
      }
      set {
        self.qwCounter.write(Tracklist.finalTracksArrayK)
        _finalTracksArray = newValue
      }
    }
    // sourcery:end
}
