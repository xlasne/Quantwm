//
//  ContextMgr.swift
//  MVVM
//
//  Created by Xavier Lasne on 08/04/16.
//  Copyright © 2016 XL Software Solutions
//

//KEYPOINT 5
// Responsible for consistent refresh of UI
// Manage view controllers dependency
// Send request to View Models, who triggers view controllers UI refresh when their matching view controller is present


import Foundation
import AppKit
import QuantwmOSX

class ContextMgr: NSObject, MonitoredClass
{
  // MARK: InterfacesMonitoredNode
    static let contextMgrK = RootDescriptor(sourceType: ContextMgr.self,
                                            description:"ContextMgr")


    func getNodeChangeCounter() -> QWChangeCounter
    {
        return changeCounter
    }
  let changeCounter = QWChangeCounter()

    static let currentFocusK = PropertyDescriptor(keypath: \ContextMgr.currentFocus,
                                                  description: "_currentFocus")
  fileprivate var _currentFocus: NSObject? = nil
  var currentFocus: NSObject? {
    get {
      self.qwRead(property: ContextMgr.currentFocusK)
      return _currentFocus
    }
    set {
      self.qwWrite(property: ContextMgr.currentFocusK)
      _currentFocus = newValue
      print("Focus has been changed")
    }
  }

    static let leftViewPresentK = PropertyDescriptor(keypath: \ContextMgr.leftViewPresent,
                                                     description: "leftViewPresent")

  fileprivate var _leftViewPresent = true
  var leftViewPresent: Bool {
    get {
      self.qwRead(property: ContextMgr.leftViewPresentK)
      return _leftViewPresent
    }
    set {
      self.qwWrite(property: ContextMgr.leftViewPresentK)
      _leftViewPresent = newValue
    }
  }

    static let rightViewPresentK = PropertyDescriptor(keypath: \ContextMgr.rightViewPresent,
                                                      description: "rightViewPresent")
  fileprivate var _rightViewPresent = true
  var rightViewPresent: Bool {
    get {
      self.qwRead(property: ContextMgr.rightViewPresentK)
      return _rightViewPresent
    }
    set {
      self.qwWrite(property: ContextMgr.rightViewPresentK)
      _rightViewPresent = newValue
    }
  }

    static let imageColorK = PropertyDescriptor(keypath: \ContextMgr.imageColor,
                                                description: "imageColor")
  fileprivate var _imageColor: NSColor = NSColor.white
  var imageColor: NSColor {
    get {
      self.qwRead(property: ContextMgr.imageColorK)
      return _imageColor
    }
    set {
      self.qwWrite(property: ContextMgr.imageColorK)
      _imageColor = newValue
    }
  }

  override init()
  {
    super.init()
  }

  func registerRoot(_ dataModel: DataModel)
  {
    dataModel.repositoryObserver.registerRoot(
      associatedObject: self,
      rootDescription: ContextMgr.contextMgrK)
  }

  func toggleLeftView()
  {
    leftViewPresent = !leftViewPresent
  }

  func toggleRightView()
  {
    rightViewPresent = !rightViewPresent
  }

  // For Monitoring<> example
  func getFocus()-> NSObject? { return currentFocus }
  func setFocus(_ focus: NSObject?) { currentFocus = focus }

}

