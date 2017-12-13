//
//  PlaylistJSON.swift
//  deezer
//
//  Created by Xavier on 03/12/2017.
//  Copyright © 2017 XL Software Solutions. All rights reserved.
//

import Foundation

struct PlaylistChunk {
    let userId: UserID
    let index: Int
    let playlists:[PlaylistJSONData]
    let total: Int
    let lastChunk: Bool
}


public class PlaylistsJSONChunk {
    public var data : Array<PlaylistJSONData>?
    public var checksum : String?
    public var total : Int?
    public var next : String?

    var playlistArray:[PlaylistJSONData]  {
        if let data = data {
            return Array(data)
        } else {
            return []
        }
    }

    func indexedPlaylists(userId: UserID, index: Int) -> PlaylistChunk {
        return PlaylistChunk(userId: userId,
                             index: index,
                             playlists: self.playlistArray,
                             total: total ?? -1,
                             lastChunk: (next == nil))
    }

    /**
     Returns an array of models based on given dictionary.

     Sample usage:
     let json4Swift_Base_list = Json4Swift_Base.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

     - parameter array:  NSArray from JSON dictionary.

     - returns: Array of Json4Swift_Base Instances.
     */
    public class func modelsFromDictionaryArray(array:NSArray) -> [PlaylistsJSONChunk]
    {
        var models:[PlaylistsJSONChunk] = []
        for item in array
        {
            models.append(PlaylistsJSONChunk(dictionary: item as! NSDictionary)!)
        }
        return models
    }

    /**
     Constructs the object based on the given dictionary.

     Sample usage:
     let json4Swift_Base = Json4Swift_Base(someDictionaryFromJSON)

     - parameter dictionary:  NSDictionary from JSON.

     - returns: Json4Swift_Base Instance.
     */
    required public init?(dictionary: NSDictionary) {

        if (dictionary["data"] != nil) { data = PlaylistJSONData.modelsFromDictionaryArray(array: dictionary["data"] as! NSArray) }
        checksum = dictionary["checksum"] as? String
        total = dictionary["total"] as? Int
        next = dictionary["next"] as? String
    }


    /**
     Returns the dictionary representation for the current instance.

     - returns: NSDictionary.
     */
    public func dictionaryRepresentation() -> NSDictionary {

        let dictionary = NSMutableDictionary()
        dictionary.setValue(self.checksum, forKey: "checksum")
        dictionary.setValue(self.total, forKey: "total")
        dictionary.setValue(self.next, forKey: "next")
        return dictionary
    }

}



/* For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar */

public class PlaylistJSONData {
    public var id : Int?
    public var title : String?
    public var duration : Int?
    public var is_loved_track : Bool?
    public var collaborative : Bool?
    public var rating : Int?
    public var nb_tracks : Int?
    public var fans : Int?
    public var link : String?
    public var picture : String?
    public var picture_small : String?
    public var picture_medium : String?
    public var picture_big : String?
    public var picture_xl : String?
    public var checksum : String?
    public var tracklist : String?
    public var creation_date : String?
    public var time_add : Int?
    public var time_mod : Int?
    public var creator : PlaylistJSONCreator?
    public var type : String?

    /**
     Returns an array of models based on given dictionary.

     Sample usage:
     let data_list = PlaylistJSONData.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

     - parameter array:  NSArray from JSON dictionary.

     - returns: Array of Data Instances.
     */
    public class func modelsFromDictionaryArray(array:NSArray) -> [PlaylistJSONData]
    {
        var models:[PlaylistJSONData] = []
        for item in array
        {
            models.append(PlaylistJSONData(dictionary: item as! NSDictionary)!)
        }
        return models
    }

    /**
     Constructs the object based on the given dictionary.

     Sample usage:
     let data = PlaylistJSONData(someDictionaryFromJSON)

     - parameter dictionary:  NSDictionary from JSON.

     - returns: Data Instance.
     */
    required public init?(dictionary: NSDictionary) {

        id = dictionary["id"] as? Int
        title = dictionary["title"] as? String
        duration = dictionary["duration"] as? Int
        is_loved_track = dictionary["is_loved_track"] as? Bool
        collaborative = dictionary["collaborative"] as? Bool
        rating = dictionary["rating"] as? Int
        nb_tracks = dictionary["nb_tracks"] as? Int
        fans = dictionary["fans"] as? Int
        link = dictionary["link"] as? String
        picture = dictionary["picture"] as? String
        picture_small = dictionary["picture_small"] as? String
        picture_medium = dictionary["picture_medium"] as? String
        picture_big = dictionary["picture_big"] as? String
        picture_xl = dictionary["picture_xl"] as? String
        checksum = dictionary["checksum"] as? String
        tracklist = dictionary["tracklist"] as? String
        creation_date = dictionary["creation_date"] as? String
        time_add = dictionary["time_add"] as? Int
        time_mod = dictionary["time_mod"] as? Int
        if (dictionary["creator"] != nil) { creator = PlaylistJSONCreator(dictionary: dictionary["creator"] as! NSDictionary) }
        type = dictionary["type"] as? String
    }


    /**
     Returns the dictionary representation for the current instance.

     - returns: NSDictionary.
     */
    public func dictionaryRepresentation() -> NSDictionary {

        let dictionary = NSMutableDictionary()

        dictionary.setValue(self.id, forKey: "id")
        dictionary.setValue(self.title, forKey: "title")
        dictionary.setValue(self.duration, forKey: "duration")
        dictionary.setValue(self.is_loved_track, forKey: "is_loved_track")
        dictionary.setValue(self.collaborative, forKey: "collaborative")
        dictionary.setValue(self.rating, forKey: "rating")
        dictionary.setValue(self.nb_tracks, forKey: "nb_tracks")
        dictionary.setValue(self.fans, forKey: "fans")
        dictionary.setValue(self.link, forKey: "link")
        dictionary.setValue(self.picture, forKey: "picture")
        dictionary.setValue(self.picture_small, forKey: "picture_small")
        dictionary.setValue(self.picture_medium, forKey: "picture_medium")
        dictionary.setValue(self.picture_big, forKey: "picture_big")
        dictionary.setValue(self.picture_xl, forKey: "picture_xl")
        dictionary.setValue(self.checksum, forKey: "checksum")
        dictionary.setValue(self.tracklist, forKey: "tracklist")
        dictionary.setValue(self.creation_date, forKey: "creation_date")
        dictionary.setValue(self.time_add, forKey: "time_add")
        dictionary.setValue(self.time_mod, forKey: "time_mod")
        dictionary.setValue(self.creator?.dictionaryRepresentation(), forKey: "creator")
        dictionary.setValue(self.type, forKey: "type")

        return dictionary
    }

}

public class PlaylistJSONCreator {
    public var id : Int?
    public var name : String?
    public var tracklist : String?
    public var type : String?

    /**
     Returns an array of models based on given dictionary.

     Sample usage:
     let creator_list = PlaylistJSONCreator.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

     - parameter array:  NSArray from JSON dictionary.

     - returns: Array of PlaylistJSONCreator Instances.
     */
    public class func modelsFromDictionaryArray(array:NSArray) -> [PlaylistJSONCreator]
    {
        var models:[PlaylistJSONCreator] = []
        for item in array
        {
            models.append(PlaylistJSONCreator(dictionary: item as! NSDictionary)!)
        }
        return models
    }

    /**
     Constructs the object based on the given dictionary.

     Sample usage:
     let creator = PlaylistJSONCreator(someDictionaryFromJSON)

     - parameter dictionary:  NSDictionary from JSON.

     - returns: PlaylistJSONCreator Instance.
     */
    required public init?(dictionary: NSDictionary) {

        id = dictionary["id"] as? Int
        name = dictionary["name"] as? String
        tracklist = dictionary["tracklist"] as? String
        type = dictionary["type"] as? String
    }


    /**
     Returns the dictionary representation for the current instance.

     - returns: NSDictionary.
     */
    public func dictionaryRepresentation() -> NSDictionary {

        let dictionary = NSMutableDictionary()

        dictionary.setValue(self.id, forKey: "id")
        dictionary.setValue(self.name, forKey: "name")
        dictionary.setValue(self.tracklist, forKey: "tracklist")
        dictionary.setValue(self.type, forKey: "type")

        return dictionary
    }

}
