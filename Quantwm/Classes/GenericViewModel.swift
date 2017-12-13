//
//  GenericViewModel.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 18/05/16.
//  Copyright © 2016 XL Software Solutions. => MIT License
//

import Foundation

public protocol QWMediatorOwner: class
{
  func getQWMediator() -> QWMediator
}

open class GenericViewModel<Model: QWMediatorOwner> : NSObject {
  open unowned var dataModel: Model

  var qwMediator : QWMediator {
    return dataModel.getQWMediator()
  }

  open let owner: NSString
  public init(dataModel : Model, owner: String)
  {
    self.dataModel = dataModel
    self.owner = NSString(string: owner)
    super.init()
  }
  // MARK: - Registration
  open func registerObserver(target: NSObject,
                             registrationDesc: QWRegistration) {
    qwMediator.registerObserver(target: target,
                                             registrationDesc: registrationDesc)
  }
  // Not mandatory. If not performed, may generate a warning.
  open func unregisterDataSet(target: NSObject) {
      qwMediator.unregisterDataSetWithTarget(target)
  }

  // MARK: - Repository Observer wrappers
  open var isUnderRefresh: Bool {
    return qwMediator.isUnderRefresh
  }

  open func updateActionAndRefresh(handler: ()->()) {
    if !isUnderRefresh {
      qwMediator.updateActionAndRefresh(owner: owner,
                                        handler: handler)
    }
    else {
      assert(false, "Warning: Trying to update during refresh")
    }
  }
}

open class QuantwmViewModel<Model: QWMediatorOwner> : NSObject, QWViewModel {
  open unowned var dataModel: Model
  open let owner: NSString
  public init(dataModel : Model, owner: String)
  {
    self.dataModel = dataModel
    self.owner = NSString(string: owner)
    super.init()
  }
  func getOwner() -> NSObject { return owner }
  public func getQWMediator() -> QWMediator { return dataModel.getQWMediator() }
}

protocol QWViewModel: QWMediatorOwner {
  func getOwner() -> NSObject
}

protocol ModelWriter: QWViewModel { }
extension ModelWriter {
  // MARK: - Repository Observer wrappers
  var isUnderRefresh: Bool {
    return self.getQWMediator().isUnderRefresh
  }

  func updateActionAndRefresh(handler: ()->()) {
    self.getQWMediator().updateActionAndRefresh(owner: self.getOwner(),
                                           handler: handler)
  }
}

protocol ModelReader: QWViewModel { }
extension ModelReader {
  // MARK: - Registration
  func registerObserver(target: NSObject,
                             registrationDesc: QWRegistration,
                             name: String? = nil) {
    self.getQWMediator().registerObserver(target: target,
                                     registrationDesc: registrationDesc)
  }
  // Not mandatory. If not performed, may generate a warning.
  func unregisterDataSet(target: NSObject) {
    self.getQWMediator().unregisterDataSetWithTarget(target)
  }
}


