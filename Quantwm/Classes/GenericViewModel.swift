//
//  GenericViewModel.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 18/05/16.
//  Copyright © 2016 XL Software Solutions. => MIT License
//

import Foundation

open class GenericViewModel<Model: QWRoot> : NSObject {
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
  open func registerObserver(registration: QWRegistration,
                             target: NSObject,
                             selector: Selector) {

    qwMediator.registerObserver(registration: registration,
                                target: target,
                                selector: selector)
  }

  // Not mandatory. If not performed, may generate a warning.
  open func unregisterDataSet(target: NSObject) {
      qwMediator.unregisterRegistrationWithTarget(target)
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

  open func refreshToken() -> QWObserverToken? {
    return qwMediator.getCurrentObserverToken()
  }

  open func asynchronousRefresh<Value>(target: NSObject, token: QWObserverToken?, handler: ()->(Value)) -> Value {
    return qwMediator.asynchronousRefresh(owner: target,
                                   token: token,
                                   handler: handler)
  }

}


