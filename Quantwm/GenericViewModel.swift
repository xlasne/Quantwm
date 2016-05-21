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

class GenericViewModel: NSObject {

    unowned var dataModel: DataModel
    unowned var dataRepositoryObserver : DataRepositoryObserver
    unowned var contextMgr  : ContextMgr
    weak var owner: NSObject?

    init(dataModel : DataModel, owner: NSObject)
    {
        self.dataModel = dataModel
        self.dataRepositoryObserver = dataModel.dataRepositoryObserver
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
        self.dataRepositoryObserver.register(target: target,
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
        self.dataRepositoryObserver.register(target: target,
                                             registrationDesc: registrationDesc,
                                             name: name)
    }

    func unregisterAll(owner: NSObject) {
        self.dataRepositoryObserver.displayUsageForOwner(owner)
        self.dataRepositoryObserver.unregisterDataSetWithTarget(owner)
    }

    // MARK: - Data Repository Observer wrappers
    func refreshUI()
    {
        dataRepositoryObserver.refreshUI()
    }

    func readOnlyAction(owner owner: NSObject?, @noescape handler: ()->())
    {
        dataRepositoryObserver.readOnlyAction(owner: owner,
                                              handler: handler)
    }

    func readOnlyActionWithReturn<T>(owner owner: NSObject?, @noescape handler: ()->(T)) -> T
    {
        return dataRepositoryObserver.readOnlyActionWithReturn(owner: owner,
                                                               handler: handler)
    }
    
    func writeAction(owner owner: NSObject?, @noescape handler: ()->())
    {
        dataRepositoryObserver.writeAction(owner: owner,
                                           handler: handler)
    }

    func writeActionAndRefresh(owner owner: NSObject?, @noescape handler: ()->()) {
        dataRepositoryObserver.writeActionAndRefresh(owner: owner,
                                                     handler: handler)
    }

}
