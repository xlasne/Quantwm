//
//  QWViewModel.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 18/05/16.
//  Copyright  MIT License
//

import Foundation

public protocol QWViewModel {

  func getMediator() -> QWMediator
  var modelOwner: String { get }

}

public extension QWViewModel {

  // MARK: - Registration
  func registerObserver(registration: QWRegistration,
                             target: NSObject,
                             selector: Selector,
                             maxNbRegistrationWithSameName: Int? = nil) {

    getMediator().registerObserver(registration: registration,
                                target: target,
                                selector: selector,
                                maxNbRegistrationWithSameName: maxNbRegistrationWithSameName)
  }

  func registerObserver(registration: QWRegistration,
                             target: AnyObject,
                             notificationClosure: @escaping () -> (),
                             maxNbRegistrationWithSameName: Int? = nil) {

    getMediator().registerObserver(registration: registration,
                                target: target,
                                notificationClosure: notificationClosure,
                                maxNbRegistrationWithSameName: maxNbRegistrationWithSameName)
  }


  // Not mandatory. If not performed, generates a warning when 2 similar objects are registered.
  func unregisterDataSet(target: AnyObject) {
    getMediator().unregisterRegistrationWithTarget(target)
  }

  // MARK: - Repository Observer wrappers
  var isUnderRefresh: Bool {
    return getMediator().isUnderRefresh
  }


  func updateActionAndRefresh(handler: ()->()) {
    if !isUnderRefresh {
      getMediator().updateActionAndRefresh(owner: modelOwner,
                                        handler: handler)
    }
    else {
      assert(false, "Warning: Trying to update during refresh")
    }
  }


  func refreshToken() -> QWObserverToken? {
    return getMediator().getCurrentObserverToken()
  }

  func asynchronousRefresh<Value>(token: QWObserverToken?, handler: ()->(Value)) -> Value {
    return getMediator().asynchronousRefresh(owner: modelOwner,
                                          token: token,
                                          handler: handler)
  }

}



