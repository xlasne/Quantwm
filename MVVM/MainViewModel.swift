//
//  MainViewModel.swift
//  MVVM
//
//  Created by Xavier Lasne on 13/04/16.
//  Copyright © 2016 XL Software Solutions
//

import Cocoa
import QuantwmOSX

class MainViewModel: GenericViewModel<DataModel>
{

  var contextMgr: ContextMgr {
    return self.dataModel.contextMgr
  }

  // MARK: Interfaces

  override init(dataModel : DataModel, owner: String)
  {
     let composedOwner = "\(owner)+MainViewModel"
     super.init(dataModel: dataModel, owner: composedOwner)
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

