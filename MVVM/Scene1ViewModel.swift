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
import QuantwmOSX

class Scene1ViewModel: GenericViewModel<DataModel>
{
  // Generic View Model
  override init(dataModel : DataModel, owner: String)
  {
    let composedOwner = "\(owner)+Scene1ViewModel"
    super.init(dataModel: dataModel, owner: composedOwner)
  }
  
  
  // MARK: - Input Processing
  // 1: First update data model variable without UI refresh
  // 2: Then update context variable with UI Refresh
  
  func updateValue(_ numberStr: String, focus: NSObject?)
  {
    
    let formatter = NumberFormatter()
    if let val = formatter.number(from: numberStr)?.intValue
    {
      updateActionAndRefresh() {
        dataModel.number1 = val
        dataModel.contextMgr.currentFocus = focus
      }
    } else {
      NSSound.beep()
    }
  }
  
  func toggleLeftView()
  {
    updateActionAndRefresh() {
      dataModel.contextMgr.toggleLeftView()
    }
  }
  
  func toggleRightView()
  {
    updateActionAndRefresh() {
      dataModel.contextMgr.toggleRightView()
    }
  }
  
  func toggleTransientAndRefresh()
  {
    updateActionAndRefresh() {
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
    updateActionAndRefresh() {
      let value = dataModel.number1
      dataModel.transientClass?.arrayVal[0].intValue += value
    }
  }
  
  
  // MARK: - Get Data Model - Read Only request
  
  //MARK: getFocus
  static let getFocusKeypathSet =
    KeypathSet(readWithRoot: ContextMgr.contextMgrK, chain: [ContextMgr.currentFocusK])
  
  func getFocus() -> NSObject? {
    let value = dataModel.contextMgr.currentFocus
    return value
  }
  
  //MARK: getValue1
  static let getValue1KeypathSet =
    KeypathSet(readWithRoot: DataModel.dataModelK, chain: [DataModel.number1K])
  
  var value1: String {
    get {
      let formatter = NumberFormatter()
      let val = dataModel.number1
      return  formatter.string(from: NSNumber(value:val)) ?? "Error"
    }
  }
  
  //MARK: getSum
  static let getInvSumKeypathSet =
    KeypathSet(readWithRoot: DataModel.dataModelK, chain: [DataModel.invSumOfNumberK])
  
  
  func getInvSum() -> Int?
  {
    return dataModel.invSumOfNumber
  }
  
  //MARK: getArraySum
  static let getArraySumKeypathSet = KeypathSet(readWithRoot: DataModel.dataModelK,
                                                chain: [DataModel.transientClassK, TransientClass.arrayValueK, NodeSwift.intValueK])
  
  func getArraySum() -> Int?
  {
    return dataModel
      .transientClass?
      .arrayVal
      .map({$0.intValue})
      .reduce(0, +)
  }
  
  
  //MARK: getTransient
  static let getTransientKeypathSet = KeypathSet(readWithRoot: DataModel.dataModelK,
                                                 chain: [DataModel.transientClassK, TransientClass.transientValK])
  
  
  func getTransient() -> String?
  {
    return dataModel
      .transientClass?
      .transientVal
  }
  
}
