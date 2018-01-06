//
//  DeezerPlaylistStub.swift
//  deezerTests
//
//  Created by Xavier Lasne on 09/12/2017.
//  Copyright  MIT License
//

import Foundation

@testable import Quantwm_Example

// Load a JSON playlist file
// Respect protocol DeezerPlaylistAPI

class DeezerPlaylistStub
{

    let jsonDict: [String: Any]

    init?(jsonFile: String) {
        do {
            let bundle = Bundle.init(for: DeezerPlaylistStub.self)
            if let file = bundle.url(forResource: jsonFile, withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                if let object = json as? [String: Any] {
                    // json is a dictionary
                    jsonDict = object
                } else if let object = json as? [Any] {
                    // json is an array
                    print(object)
                    return nil
                } else {
                    print("JSON is invalid")
                    return nil
                }
            } else {
                print("no file")
                return nil
            }
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func getChunk() -> PlaylistsJSONChunk {
        let chunk = PlaylistsJSONChunk(dictionary: self.jsonDict as NSDictionary)!
        return chunk
    }

    static func importPlaylistChunk(dataModel: DataModel, index: Int, chunk: Int) {
        let jsonStub = DeezerPlaylistStub(jsonFile: "DeezerPlaylist\(chunk)")
        let jsonChunk = jsonStub!.getChunk()
        let playlistChunk = jsonChunk.indexedPlaylists(userId: dataModel.userId, index: index)
        dataModel.playlistsCollection.importChunck(chunk: playlistChunk)
    }


}
