//
//  QWViewModel.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 18/05/16.
//  Copyright  MIT License
//

import Foundation

open class QWViewModel<Mediator: QWMediator>: NSObject {

  public unowned var qwMediator : Mediator

  open let owner: String
  public init(mediator: Mediator, owner: String)
  {
    self.qwMediator = mediator
    self.owner = owner
    super.init()
  }

  // MARK: - Registration
  open func registerObserver(registration: QWRegistration,
                             target: NSObject,
                             selector: Selector,
                             maxNbRegistrationWithSameName: Int? = nil) {

    qwMediator.registerObserver(registration: registration,
                                target: target,
                                selector: selector,
                                maxNbRegistrationWithSameName: maxNbRegistrationWithSameName)
  }

  open func registerObserver(registration: QWRegistration,
                             target: AnyObject,
                             notificationClosure: @escaping () -> (),
                             maxNbRegistrationWithSameName: Int? = nil) {

    qwMediator.registerObserver(registration: registration,
                                target: target,
                                notificationClosure: notificationClosure,
                                maxNbRegistrationWithSameName: maxNbRegistrationWithSameName)
  }


  // Not mandatory. If not performed, generates a warning when 2 similar objects are registered.
  open func unregisterDataSet(target: AnyObject) {
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

  open func asynchronousRefresh<Value>(token: QWObserverToken?, handler: ()->(Value)) -> Value {
    return qwMediator.asynchronousRefresh(owner: owner,
                                   token: token,
                                   handler: handler)
  }

}


