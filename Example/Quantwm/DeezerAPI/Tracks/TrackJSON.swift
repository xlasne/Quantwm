//
//  TrackJSON.swift
//
//  Created by Xavier on 03/12/2017.
//  Copyright (c) 2017 Swift Models Generated from JSON powered by http://www.json4swift.com
//


import Foundation

struct TrackChunk {
    let playlistId: PlaylistID
    let index: Int
    let data:[TrackDataJSON]
    let total: Int
    let lastChunk: Bool
}

public class TrackJSONChunk {
    public var checksum : String?
    public var data : Array<TrackDataJSON>?
    public var total : Int?
    public var next : String?

    var tracksArray:[TrackDataJSON]  {
        if let data = data {
            return Array(data)
        } else {
            return []
        }
    }


    func indexedTracks(playlistId: PlaylistID, index: Int) -> TrackChunk {
        return TrackChunk(playlistId: playlistId,
                             index: index,
                             data: self.tracksArray,
                             total: total ?? -1,
                             lastChunk: (next == nil))
    }


    /**
     Returns an array of models based on given dictionary.

     Sample usage:
     let json4Swift_Base_list = Json4Swift_Base.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

     - parameter array:  NSArray from JSON dictionary.

     - returns: Array of TrackJSON Instances.
     */
    public class func modelsFromDictionaryArray(array:NSArray) -> [TrackJSONChunk]
    {
        var models:[TrackJSONChunk] = []
        for item in array
        {
            models.append(TrackJSONChunk(dictionary: item as! NSDictionary)!)
        }
        return models
    }

    /**
     Constructs the object based on the given dictionary.

     Sample usage:
     let json4Swift_Base = Json4Swift_Base(someDictionaryFromJSON)

     - parameter dictionary:  NSDictionary from JSON.

     - returns: TrackDataJSON Instance.
     */
    required public init?(dictionary: NSDictionary) {

        if (dictionary["data"] != nil) {
            data = TrackDataJSON.modelsFromDictionaryArray(array: dictionary["data"] as! NSArray)
        }
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

        return dictionary
    }

}


public class AlbumJSON_1 {
    public var cover : String?
    public var cover_big : String?
    public var cover_medium : String?
    public var cover_small : String?
    public var cover_xl : String?
    public var id : Int?
    public var title : String?
    public var tracklist : String?
    public var type : String?

    /**
     Returns an array of models based on given dictionary.

     Sample usage:
     let album_list = AlbumJSON_1.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

     - parameter array:  NSArray from JSON dictionary.

     - returns: Array of AlbumJSON_1 Instances.
     */
    public class func modelsFromDictionaryArray(array:NSArray) -> [AlbumJSON_1]
    {
        var models:[AlbumJSON_1] = []
        for item in array
        {
            models.append(AlbumJSON_1(dictionary: item as! NSDictionary)!)
        }
        return models
    }

    /**
     Constructs the object based on the given dictionary.

     Sample usage:
     let AlbumJSON_1 = AlbumJSON_1(someDictionaryFromJSON)

     - parameter dictionary:  NSDictionary from JSON.

     - returns: AlbumJSON_1 Instance.
     */
    required public init?(dictionary: NSDictionary) {

        cover = dictionary["cover"] as? String
        cover_big = dictionary["cover_big"] as? String
        cover_medium = dictionary["cover_medium"] as? String
        cover_small = dictionary["cover_small"] as? String
        cover_xl = dictionary["cover_xl"] as? String
        id = dictionary["id"] as? Int
        title = dictionary["title"] as? String
        tracklist = dictionary["tracklist"] as? String
        type = dictionary["type"] as? String
    }


    /**
     Returns the dictionary representation for the current instance.

     - returns: NSDictionary.
     */
    public func dictionaryRepresentation() -> NSDictionary {

        let dictionary = NSMutableDictionary()

        dictionary.setValue(self.cover, forKey: "cover")
        dictionary.setValue(self.cover_big, forKey: "cover_big")
        dictionary.setValue(self.cover_medium, forKey: "cover_medium")
        dictionary.setValue(self.cover_small, forKey: "cover_small")
        dictionary.setValue(self.cover_xl, forKey: "cover_xl")
        dictionary.setValue(self.id, forKey: "id")
        dictionary.setValue(self.title, forKey: "title")
        dictionary.setValue(self.tracklist, forKey: "tracklist")
        dictionary.setValue(self.type, forKey: "type")

        return dictionary
    }

}


public class TrackDataJSON {
    public var album : AlbumJSON_1?
    public var alternative : Alternative?
    public var artist : Artist?
    public var duration : Int?
    public var explicit_lyrics : Bool?
    public var id : Int?
    public var link : String?
    public var preview : String?
    public var rank : Int?
    public var readable : Bool?
    public var time_add : Int?
    public var title : String?
    public var title_short : String?
    public var title_version : String?
    public var type : String?

    /**
     Returns an array of models based on given dictionary.

     Sample usage:
     let data_list = Data.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

     - parameter array:  NSArray from JSON dictionary.

     - returns: Array of Data Instances.
     */
    public class func modelsFromDictionaryArray(array:NSArray) -> [TrackDataJSON]
    {
        var models:[TrackDataJSON] = []
        for item in array
        {
            models.append(TrackDataJSON(dictionary: item as! NSDictionary)!)
        }
        return models
    }

    /**
     Constructs the object based on the given dictionary.

     Sample usage:
     let data = TrackDataJSON(someDictionaryFromJSON)

     - parameter dictionary:  NSDictionary from JSON.

     - returns: TrackDataJSON Instance.
     */
    required public init?(dictionary: NSDictionary) {

        if (dictionary["album"] != nil) { album = AlbumJSON_1(dictionary: dictionary["album"] as! NSDictionary) }
        if (dictionary["alternative"] != nil) { alternative = Alternative(dictionary: dictionary["alternative"] as! NSDictionary) }
        if (dictionary["artist"] != nil) { artist = Artist(dictionary: dictionary["artist"] as! NSDictionary) }
        duration = dictionary["duration"] as? Int
        explicit_lyrics = dictionary["explicit_lyrics"] as? Bool
        id = dictionary["id"] as? Int
        link = dictionary["link"] as? String
        preview = dictionary["preview"] as? String
        rank = dictionary["rank"] as? Int
        readable = dictionary["readable"] as? Bool
        time_add = dictionary["time_add"] as? Int
        title = dictionary["title"] as? String
        title_short = dictionary["title_short"] as? String
        title_version = dictionary["title_version"] as? String
        type = dictionary["type"] as? String
    }


    /**
     Returns the dictionary representation for the current instance.

     - returns: NSDictionary.
     */
    public func dictionaryRepresentation() -> NSDictionary {

        let dictionary = NSMutableDictionary()

        dictionary.setValue(self.album?.dictionaryRepresentation(), forKey: "album")
        dictionary.setValue(self.alternative?.dictionaryRepresentation(), forKey: "alternative")
        dictionary.setValue(self.artist?.dictionaryRepresentation(), forKey: "artist")
        dictionary.setValue(self.duration, forKey: "duration")
        dictionary.setValue(self.explicit_lyrics, forKey: "explicit_lyrics")
        dictionary.setValue(self.id, forKey: "id")
        dictionary.setValue(self.link, forKey: "link")
        dictionary.setValue(self.preview, forKey: "preview")
        dictionary.setValue(self.rank, forKey: "rank")
        dictionary.setValue(self.readable, forKey: "readable")
        dictionary.setValue(self.time_add, forKey: "time_add")
        dictionary.setValue(self.title, forKey: "title")
        dictionary.setValue(self.title_short, forKey: "title_short")
        dictionary.setValue(self.title_version, forKey: "title_version")
        dictionary.setValue(self.type, forKey: "type")

        return dictionary
    }

}


public class Alternative {
    public var album : AlbumJSON_1?
    public var artist : Artist?
    public var duration : Int?
    public var explicit_lyrics : Bool?
    public var id : Int?
    public var link : String?
    public var preview : String?
    public var rank : Int?
    public var readable : Bool?
    public var title : String?
    public var title_short : String?
    public var title_version : String?
    public var type : String?

    /**
     Returns an array of models based on given dictionary.

     Sample usage:
     let alternative_list = Alternative.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

     - parameter array:  NSArray from JSON dictionary.

     - returns: Array of Alternative Instances.
     */
    public class func modelsFromDictionaryArray(array:NSArray) -> [Alternative]
    {
        var models:[Alternative] = []
        for item in array
        {
            models.append(Alternative(dictionary: item as! NSDictionary)!)
        }
        return models
    }

    /**
     Constructs the object based on the given dictionary.

     Sample usage:
     let alternative = Alternative(someDictionaryFromJSON)

     - parameter dictionary:  NSDictionary from JSON.

     - returns: Alternative Instance.
     */
    required public init?(dictionary: NSDictionary) {

        if (dictionary["album"] != nil) { album = AlbumJSON_1(dictionary: dictionary["album"] as! NSDictionary) }
        if (dictionary["artist"] != nil) { artist = Artist(dictionary: dictionary["artist"] as! NSDictionary) }
        duration = dictionary["duration"] as? Int
        explicit_lyrics = dictionary["explicit_lyrics"] as? Bool
        id = dictionary["id"] as? Int
        link = dictionary["link"] as? String
        preview = dictionary["preview"] as? String
        rank = dictionary["rank"] as? Int
        readable = dictionary["readable"] as? Bool
        title = dictionary["title"] as? String
        title_short = dictionary["title_short"] as? String
        title_version = dictionary["title_version"] as? String
        type = dictionary["type"] as? String
    }


    /**
     Returns the dictionary representation for the current instance.

     - returns: NSDictionary.
     */
    public func dictionaryRepresentation() -> NSDictionary {

        let dictionary = NSMutableDictionary()

        dictionary.setValue(self.album?.dictionaryRepresentation(), forKey: "album")
        dictionary.setValue(self.artist?.dictionaryRepresentation(), forKey: "artist")
        dictionary.setValue(self.duration, forKey: "duration")
        dictionary.setValue(self.explicit_lyrics, forKey: "explicit_lyrics")
        dictionary.setValue(self.id, forKey: "id")
        dictionary.setValue(self.link, forKey: "link")
        dictionary.setValue(self.preview, forKey: "preview")
        dictionary.setValue(self.rank, forKey: "rank")
        dictionary.setValue(self.readable, forKey: "readable")
        dictionary.setValue(self.title, forKey: "title")
        dictionary.setValue(self.title_short, forKey: "title_short")
        dictionary.setValue(self.title_version, forKey: "title_version")
        dictionary.setValue(self.type, forKey: "type")

        return dictionary
    }

}

public class Artist {
    public var id : Int?
    public var link : String?
    public var name : String?
    public var picture : String?
    public var picture_big : String?
    public var picture_medium : String?
    public var picture_small : String?
    public var picture_xl : String?
    public var tracklist : String?
    public var type : String?

    /**
     Returns an array of models based on given dictionary.

     Sample usage:
     let artist_list = Artist.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

     - parameter array:  NSArray from JSON dictionary.

     - returns: Array of Artist Instances.
     */
    public class func modelsFromDictionaryArray(array:NSArray) -> [Artist]
    {
        var models:[Artist] = []
        for item in array
        {
            models.append(Artist(dictionary: item as! NSDictionary)!)
        }
        return models
    }

    /**
     Constructs the object based on the given dictionary.

     Sample usage:
     let artist = Artist(someDictionaryFromJSON)

     - parameter dictionary:  NSDictionary from JSON.

     - returns: Artist Instance.
     */
    required public init?(dictionary: NSDictionary) {

        id = dictionary["id"] as? Int
        link = dictionary["link"] as? String
        name = dictionary["name"] as? String
        picture = dictionary["picture"] as? String
        picture_big = dictionary["picture_big"] as? String
        picture_medium = dictionary["picture_medium"] as? String
        picture_small = dictionary["picture_small"] as? String
        picture_xl = dictionary["picture_xl"] as? String
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
        dictionary.setValue(self.link, forKey: "link")
        dictionary.setValue(self.name, forKey: "name")
        dictionary.setValue(self.picture, forKey: "picture")
        dictionary.setValue(self.picture_big, forKey: "picture_big")
        dictionary.setValue(self.picture_medium, forKey: "picture_medium")
        dictionary.setValue(self.picture_small, forKey: "picture_small")
        dictionary.setValue(self.picture_xl, forKey: "picture_xl")
        dictionary.setValue(self.tracklist, forKey: "tracklist")
        dictionary.setValue(self.type, forKey: "type")
        return dictionary
    }

}

/*
 Copyright (c) 2017 Swift Models Generated from JSON powered by http://www.json4swift.com

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
