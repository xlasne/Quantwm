//
//  Document.swift
//  MVVM
//
//  Created by Xavier on 08/04/16.
//  Copyright © 2016 XL Software Solutions
//


import Cocoa

class Document: NSDocument {

    var dataModel: DataModel

    var dataRepositoryObserver: DataRepositoryObserver {
        return self.dataModel.dataRepositoryObserver
    }

    override init() {
        self.dataModel = DataModel()
        super.init()
        self.dataModel.postInit(document: self)
        // Add your subclass-specific initialization here.
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateControllerWithIdentifier("Document Window Controller") as! NSWindowController
        self.addWindowController(windowController)
    }

    override func dataOfType(typeName: String) throws -> NSData {
        return NSKeyedArchiver.archivedDataWithRootObject(dataModel)
    }

    override func readFromData(data: NSData, ofType typeName: String) throws {
        if let model = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? DataModel {
            self.dataModel = model
        } else {
            self.dataModel = DataModel()
        }
        self.dataModel.postInit(document: self)
    }

    func windowDidDeminiaturize(notification: NSNotification)
    {
        self.dataModel.postInit(document: self)
    }

}

