//
//  MainViewModel.swift
//  MVVM
//
//  Created by Xavier Lasne on 13/04/16.
//  Copyright © 2016 XL Software Solutions
//

import Cocoa

class MainViewModel: GenericViewModel<DataModel>
{

  var contextMgr: ContextMgr {
    return self.dataModel.contextMgr.observed
  }

  // MARK: Interfaces

  init(dataModel : DataModel, viewController : MainViewController)
  {
    super.init(dataModel: dataModel, owner: viewController)
  }

  static let leftViewPresentKeypathSet =
    KeypathSet(readWithRoot:ContextMgr.contextMgrK, chain: [ContextMgr.leftViewPresentK])

  var leftViewPresent: Bool {
    let contextMgr = repositoryObserver.rootForKey(ContextMgr.contextMgrK) as? ContextMgr
    return contextMgr?.leftViewPresent ?? false
  }

  static let rightViewPresentKeypathSet =
    KeypathSet(readWithRoot:ContextMgr.contextMgrK, chain: [ContextMgr.rightViewPresentK])

  var rightViewPresent: Bool {
    return contextMgr.rightViewPresent
  }
  
}

