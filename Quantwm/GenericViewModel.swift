//
//  GenericViewModel.swift
//  QUANTWM
//
//  Created by Xavier on 18/05/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import Foundation

protocol RepositoryHolder: class
{
    func getRepositoryObserver() -> RepositoryObserver
}

class GenericViewModel<Model: RepositoryHolder> : NSObject {

    unowned var dataModel: Model
    unowned var repositoryObserver : RepositoryObserver
    weak var owner: NSObject?

    init(dataModel : Model, owner: NSObject)
    {
        self.dataModel = dataModel
        self.repositoryObserver = dataModel.getRepositoryObserver()
        self.owner = owner
        super.init()
    }

    // MARK: - Registration
    func register(target target: NSObject,
                         selector: Selector,
                         keypathDescriptionSet: Set<KeypathDescription>,
                         name: String,
                         writtenPropertySet: Set<PropertyDescription> = [],
                         maximumAllowedRegistrationWithSameTypeSelector: Int? = nil)
    {
        self.repositoryObserver.register(target: target,
                                   selector: selector,
                                   keypathDescriptionSet: keypathDescriptionSet,
                                   name: name,
                                   writtenPropertySet: writtenPropertySet,
                                   maximumAllowedRegistrationWithSameTypeSelector: maximumAllowedRegistrationWithSameTypeSelector)
    }

    func register(target target: NSObject,
                         registrationDesc: RegisterDescription,
                         name: String? = nil)
    {
        self.repositoryObserver.register(target: target,
                                             registrationDesc: registrationDesc,
                                             name: name)
    }

    func unregisterAll(owner: NSObject) {
        self.repositoryObserver.displayUsageForOwner(owner)
        self.repositoryObserver.unregisterDataSetWithTarget(owner)
    }

    // MARK: - Repository Observer wrappers
    func refreshUI()
    {
        repositoryObserver.refreshUI()
    }

    func loadAction(owner owner: NSObject?, @noescape handler: ()->())
    {
        repositoryObserver.loadAction(owner: owner,
                                              handler: handler)
    }

    func loadActionWithReturn<T>(owner owner: NSObject?, @noescape handler: ()->(T)) -> T
    {
        return repositoryObserver.loadActionWithReturn(owner: owner,
                                                               handler: handler)
    }
    
    func updateAction(owner owner: NSObject?, @noescape handler: ()->())
    {
        repositoryObserver.updateAction(owner: owner,
                                           handler: handler)
    }

    func updateActionAndRefresh(owner owner: NSObject?, @noescape handler: ()->()) {
        repositoryObserver.updateActionAndRefresh(owner: owner,
                                                     handler: handler)
    }

}
