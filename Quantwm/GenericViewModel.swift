//
//  GenericViewModel.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 18/05/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import Foundation

public protocol RepositoryHolder: class
{
  func getRepositoryObserver() -> RepositoryObserver
}

public class GenericViewModel<Model: RepositoryHolder> : NSObject {

  public unowned var dataModel: Model
  public unowned var repositoryObserver : RepositoryObserver
  public weak var owner: NSObject?

  public init(dataModel : Model, owner: NSObject)
  {
    self.dataModel = dataModel
    self.repositoryObserver = dataModel.getRepositoryObserver()
    self.owner = owner
    super.init()
  }

  // MARK: - Registration
  public func registerObserver(target target: NSObject,
                              selector: Selector,
                              keypathDescriptionSet: Set<KeypathDescription>,
                              name: String,
                              writtenPropertySet: Set<PropertyDescription> = [],
                              maximumAllowedRegistrationWithSameTypeSelector: Int? = nil)
  {
    self.repositoryObserver.registerObserver(target: target,
                                     selector: selector,
                                     keypathDescriptionSet: keypathDescriptionSet,
                                     name: name,
                                     writtenPropertySet: writtenPropertySet,
                                     maximumAllowedRegistrationWithSameTypeSelector: maximumAllowedRegistrationWithSameTypeSelector)
  }

  public func registerObserver(target target: NSObject,
                              registrationDesc: RegisterDescription,
                              name: String? = nil)
  {
    self.repositoryObserver.registerObserver(target: target,
                                     registrationDesc: registrationDesc,
                                     name: name)
  }

  public func registerForEachCycle(target: NSObject,
                                   selector: Selector,
                                   name: String,
                                   maximumAllowedRegistrationWithSameTypeSelector: Int? = nil)
  {
    self.repositoryObserver.registerForEachCycle(target: target,
                                                 selector: selector,
                                                 name: name,
                                                 maximumAllowedRegistrationWithSameTypeSelector: maximumAllowedRegistrationWithSameTypeSelector)
  }

  public func unregisterAll(owner: NSObject) {
    self.repositoryObserver.displayUsageForOwner(owner)
    self.repositoryObserver.unregisterDataSetWithTarget(owner)
  }

  // MARK: - Repository Observer wrappers
  public func refreshUI()
  {
    repositoryObserver.refreshUI()
  }

  public func loadAction(owner owner: NSObject?, @noescape handler: ()->())
  {
    repositoryObserver.loadAction(owner: owner,
                                  handler: handler)
  }

  public func loadActionWithReturn<T>(owner owner: NSObject?, @noescape handler: ()->(T)) -> T
  {
    return repositoryObserver.loadActionWithReturn(owner: owner,
                                                   handler: handler)
  }

  public func updateAction(owner owner: NSObject?, @noescape handler: ()->())
  {
    repositoryObserver.updateAction(owner: owner,
                                    handler: handler)
  }

  public func updateActionAndRefresh(owner owner: NSObject?, @noescape handler: ()->()) {
    repositoryObserver.updateActionAndRefresh(owner: owner,
                                              handler: handler)
  }

  public func updateActionIfPossibleElseDispatch(owner owner: NSObject?, escapingHandler: ()->())
  {
    repositoryObserver.updateActionIfPossibleElseDispatch(owner: owner,
                                                          escapingHandler: escapingHandler)
  }

}
