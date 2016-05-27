//
//  GenericViewModel.swift
//  QUANTWM
//
//  Created by Xavier on 18/05/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import Foundation

//
//  Generic View Model.swift
//  Spiky
//
//  Created by Xavier on 08/05/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import Foundation

class GenericViewModel : NSObject {

    unowned var dataModel: DataModel
    unowned var repositoryObserver : RepositoryObserver
    unowned var contextMgr  : ContextMgr
    weak var owner: NSObject?

    init(dataModel : DataModel, owner: NSObject)
    {
        self.dataModel = dataModel
        self.repositoryObserver = dataModel.repositoryObserver
        self.contextMgr   = dataModel.contextMgr
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
