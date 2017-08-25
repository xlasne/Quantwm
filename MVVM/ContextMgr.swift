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
    static let contextMgrK = RootDescriptor(description:"ContextMgr",
                                            sourceType: ContextMgr.self)


    func getNodeChangeCounter() -> ChangeCounter
    {
        return changeCounter
    }
  let changeCounter = ChangeCounter()

  var observed: ContextMgr {
    return self
  }

    static let currentFocusK = PropertyDescriptor(keypath: \ContextMgr.currentFocus,
                                                  description: "_currentFocus")
  fileprivate var _currentFocus: NSObject? = nil
  var currentFocus: NSObject? {
    get {
      self.changeCounter.performedReadOnMainThread(ContextMgr.currentFocusK)
      return _currentFocus
    }
    set {
      self.changeCounter.performedWriteOnMainThread(ContextMgr.currentFocusK)
      _currentFocus = newValue
      print("Focus has been changed")
    }
  }

    static let leftViewPresentK = PropertyDescriptor(keypath: \ContextMgr.leftViewPresent,
                                                     description: "leftViewPresent")

  fileprivate var _leftViewPresent = true
  var leftViewPresent: Bool {
    get {
      self.changeCounter.performedReadOnMainThread(ContextMgr.leftViewPresentK)
      return _leftViewPresent
    }
    set {
      self.changeCounter.performedWriteOnMainThread(ContextMgr.leftViewPresentK)
      _leftViewPresent = newValue
    }
  }

    static let rightViewPresentK = PropertyDescriptor(keypath: \ContextMgr.rightViewPresent,
                                                      description: "rightViewPresent")
  fileprivate var _rightViewPresent = true
  var rightViewPresent: Bool {
    get {
      self.changeCounter.performedReadOnMainThread(ContextMgr.rightViewPresentK)
      return _rightViewPresent
    }
    set {
      self.changeCounter.performedWriteOnMainThread(ContextMgr.rightViewPresentK)
      _rightViewPresent = newValue
    }
  }

    static let imageColorK = PropertyDescriptor(keypath: \ContextMgr.imageColor,
                                                description: "imageColor")
  fileprivate var _imageColor: NSColor = NSColor.white
  var imageColor: NSColor {
    get {
      self.changeCounter.performedReadOnMainThread(ContextMgr.imageColorK)
      return _imageColor
    }
    set {
      self.changeCounter.performedWriteOnMainThread(ContextMgr.imageColorK)
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
      changeCounter: self.changeCounter,
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

