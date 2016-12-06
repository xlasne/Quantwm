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
    open let owner: NSString
    var registeredSelectorArray : [Selector]


    public init(dataModel : Model, owner: String)
    {
        self.dataModel = dataModel
        self.repositoryObserver = dataModel.getRepositoryObserver()
        self.owner = NSString(string: owner)
        self.registeredSelectorArray = []
        super.init()
    }

    deinit {
        // Can not keep a reference to the target here, as target weak or unowned reference 
        // are zeroed when reaching this point.
        // -> Owner is build as a string containing the name of the view controller + view model
        self.repositoryObserver.displayUsage(owner: owner)
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

    open func unregisterDataSet(target: NSObject)
    {
        self.repositoryObserver.unregisterDataSetWithTarget(target)
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
