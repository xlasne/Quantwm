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

open class GenericViewModel<Model: RepositoryHolder> : NSObject {

    open unowned var dataModel: Model
    open unowned var repositoryObserver : RepositoryObserver
    open unowned var owner: NSObject
    var registeredSelectorArray : [Selector]


    public init(dataModel : Model, owner: NSObject)
    {
        self.dataModel = dataModel
        self.repositoryObserver = dataModel.getRepositoryObserver()
        self.owner = owner
        self.registeredSelectorArray = []
        super.init()
    }

    deinit {
        self.repositoryObserver.displayUsageForOwner(owner)
        for selector in registeredSelectorArray {
            self.repositoryObserver.unregisterDataSetWithTarget(owner, selector: selector)
        }
        self.registeredSelectorArray = []
    }


    // MARK: - Registration
    open func registerObserver(target: NSObject,
                               selector: Selector,
                               keypathDescriptionSet: Set<KeypathDescription>,
                               name: String,
                               writtenPropertySet: Set<PropertyDescription> = [],
                               maximumAllowedRegistrationWithSameTypeSelector: Int? = nil)
    {
        self.registeredSelectorArray.append(selector)
        self.repositoryObserver.registerObserver(target: target,
                                                 selector: selector,
                                                 keypathDescriptionSet: keypathDescriptionSet,
                                                 name: name,
                                                 writtenPropertySet: writtenPropertySet,
                                                 maximumAllowedRegistrationWithSameTypeSelector: maximumAllowedRegistrationWithSameTypeSelector)
    }

    open func registerObserver(target: NSObject,
                               registrationDesc: RegisterDescription,
                               name: String? = nil)
    {
        self.registeredSelectorArray.append(registrationDesc.selector)
        self.repositoryObserver.registerObserver(target: target,
                                                 registrationDesc: registrationDesc,
                                                 name: name)
    }

    open func registerForEachCycle(_ target: NSObject,
                                   selector: Selector,
                                   name: String,
                                   maximumAllowedRegistrationWithSameTypeSelector: Int? = nil)
    {
        self.registeredSelectorArray.append(selector)
        self.repositoryObserver.registerForEachCycle(target: target,
                                                     selector: selector,
                                                     name: name,
                                                     maximumAllowedRegistrationWithSameTypeSelector: maximumAllowedRegistrationWithSameTypeSelector)
    }

    // MARK: - Repository Observer wrappers
    open func refreshUI()
    {
        repositoryObserver.refreshUI()
    }

    open func loadAction(handler: ()->())
    {
        repositoryObserver.loadAction(owner: owner,
                                      handler: handler)
    }

    open func loadActionWithReturn<T>(handler: ()->(T)) -> T
    {
        return repositoryObserver.loadActionWithReturn(owner: owner,
                                                       handler: handler)
    }

    open func updateAction(handler: ()->())
    {
        repositoryObserver.updateAction(owner: owner,
                                        handler: handler)
    }

    open func updateActionAndRefresh(handler: ()->()) {
        repositoryObserver.updateActionAndRefresh(owner: owner,
                                                  handler: handler)
    }

    open func updateActionIfPossibleElseDispatch(escapingHandler: @escaping ()->())
    {
        repositoryObserver.updateActionIfPossibleElseDispatch(owner: owner,
                                                              escapingHandler: escapingHandler)
    }
    
}
