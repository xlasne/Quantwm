//
//  Scene1ViewModel.swift
//  MVVM
//
//  Created by Xavier Lasne on 08/04/16.
//  Copyright © 2016 XL Software Solutions
//

// KEYPOINT 4

// - View Model belong to the Data Model hierarchy, and are always instantiated
// - View Models have 3 sections
//
// Input Section
//     1: Update Data Model
//     2: Update Context Mgr and Trigger UI Refresh
//
// Refresh Section:
//     Update matching VC if present
//
// Accessor:
//     Process read request toward DataModel and/or Context Mgr
//
// Remark: there is a 1 to 1 relationship between View Model and View Controller
// Maintained by weak reference on both sides
// I don't use protocol because it is extra lines with little gain because of this 1 to 1 relationship.

import Foundation
import AppKit

class Scene1ViewModel: GenericViewModel<DataModel>
{
  // Generic View Model
  init(dataModel : DataModel, viewController: Scene1ViewController)
  {
    super.init(dataModel: dataModel, owner: viewController)
  }


  // MARK: - Input Processing
  // 1: First update data model variable without UI refresh
  // 2: Then update context variable with UI Refresh

  func updateValue(numberStr: String, focus: NSObject?)
  {

    let formatter = NSNumberFormatter()
    if let val = formatter.numberFromString(numberStr)?.integerValue
    {
      updateActionAndRefresh(owner: owner) {
        dataModel.observedSelf.number1 = val
        dataModel.contextMgr.currentFocus = focus
      }
    } else {
      NSBeep()
    }
  }

  func toggleLeftView()
  {
    updateActionAndRefresh(owner: owner) {
      dataModel.contextMgr.toggleLeftView()
    }
  }

  func toggleRightView()
  {
    updateActionAndRefresh(owner: owner) {
      dataModel.contextMgr.toggleRightView()
    }
  }

  func toggleTransientAndRefresh()
  {
    updateActionAndRefresh(owner: owner) {
      if let _ = self.dataModel.transientClass {
        print("Removing Transient")
        dataModel.removeTransient()
      } else {
        print("Creating Transient")
        dataModel.createTransient()
      }
    }
  }

  func transientAddtoArray()
  {
    updateActionAndRefresh(owner: owner) {
      let value = dataModel.number1
      dataModel.transientClass?.arrayVal[0].intValue += value
    }
  }


  // MARK: - Get Data Model - Read Only request

  //MARK: getFocus
  static let getFocusKeypathSet =
    KeypathSet(readWithRoot: ContextMgr.contextMgrK, chain: [ContextMgr.currentFocusK])

  func getFocus() -> NSObject? {
    let value = dataModel.contextMgr.observed.currentFocus
    return value
  }

  //MARK: getValue1
  static let getValue1KeypathSet =
    KeypathSet(readWithRoot: DataModel.dataModelK, chain: [DataModel.number1K])

  var value1: String {
    get {
      let formatter = NSNumberFormatter()
      let val = dataModel.observedSelf.number1
      return  formatter.stringFromNumber(val) ?? "Error"
    }
  }

  //MARK: getSum
  static let getInvSumKeypathSet =
    KeypathSet(readWithRoot: DataModel.dataModelK, chain: [DataModel.invSumOfNumberK])


  func getInvSum() -> Int?
  {
    return dataModel.observedSelf.invSumOfNumber
  }

  //MARK: getArraySum
  static let getArraySumKeypathSet = KeypathSet(readWithRoot: DataModel.dataModelK,
                                                chain: [DataModel.transientClassK, TransientClass.arrayValueK, NodeObjc.intValueK()])

  func getArraySum() -> Int?
  {
    return dataModel
      .observedSelf
      .transientClass?
      .arrayVal
      .map({$0.intValue})
      .reduce(0, combine: +)
  }


  //MARK: getTransient
  static let getTransientKeypathSet = KeypathSet(readWithRoot: DataModel.dataModelK,
                                                 chain: [DataModel.transientClassK, TransientClass.transientValK])


  func getTransient() -> String?
  {
    return dataModel
      .observedSelf
      .transientClass?
      .transientVal
  }

}