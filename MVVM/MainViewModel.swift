//
//  MainViewModel.swift
//  MVVM
//
//  Created by Xavier on 13/04/16.
//  Copyright © 2016 XL Software Solutions
//

import Cocoa

class MainViewModel: GenericViewModel<DataModel>
{

    // MARK: Interfaces

    init(dataModel : DataModel, viewController : MainViewController)
    {
        super.init(dataModel: dataModel, owner: viewController)
    }

    static func getLeftRightKeypaths() -> Set<KeypathDescription>
    {
        let leftM = KeypathDescription(root:ContextMgr.contextMgrK, chain: [ContextMgr._leftViewPresentK])
        let rightM = KeypathDescription(root:ContextMgr.contextMgrK, chain:[ContextMgr._rightViewPresentK])
        return Set([leftM, rightM])
    }

    var leftViewPresent: Bool {
        return self.dataModel.contextMgr.observed.leftViewPresent
    }

    var rightViewPresent: Bool {
        return self.dataModel.contextMgr.observed.rightViewPresent
    }

}

