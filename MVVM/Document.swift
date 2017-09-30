//
//  DemoDocument.swift
//  MVVM
//
//  Created by Xavier Lasne on 08/04/16.
//  Copyright © 2016 XL Software Solutions
//


import Cocoa
import QuantwmOSX

class DemoDocument: NSDocument {
  
  var dataModel: DataModel
  
  var repositoryObserver: RepositoryObserver {
    return self.dataModel.repositoryObserver
  }
  
  override init() {
    self.dataModel = DataModel()
    super.init()
    self.dataModel.postInit(document: self)
    // Add your subclass-specific initialization here.
  }
  
  override class var autosavesInPlace: Bool {
    return true
  }
  
  override func makeWindowControllers() {
    // Returns the Storyboard that contains your DemoDocument window.
    let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
    let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Document Window Controller")) as! NSWindowController
    self.addWindowController(windowController)
  }
  
  override func data(ofType typeName: String) throws -> Data {
    // TODO: Migrate to 10.12 and implement Codable
    let data = NSData()
    return NSKeyedArchiver.archivedData(withRootObject: data)
  }
  
  override func read(from data: Data, ofType typeName: String) throws {
    // TODO: Migrate to 10.12 and implement Codable
    self.dataModel = DataModel()
    self.dataModel.postInit(document: self)
  }


  func windowDidDeminiaturize(_ notification: Notification)
  {
    self.dataModel.postInit(document: self)
  }
  
}

