//
//  Scene2ViewModel.swift
//  MVVM
//
//  Created by Xavier Lasne on 08/04/16.
//  Copyright © 2016 XL Software Solutions
//

import Foundation
import AppKit

class Scene2ViewModel: GenericViewModel<DataModel>
{
  // Generic View Model
  init(dataModel : DataModel, viewController: Scene2ViewController)
  {
    super.init(dataModel: dataModel, owner: viewController)
  }

  // MARK: - Input Processing
  func setValue2(_ numberStr: String, focus: NSObject?)
  {
    let formatter = NumberFormatter()
    if let val = formatter.number(from: numberStr)?.intValue
    {
      updateActionAndRefresh(owner: owner) {
        if val != self.dataModel.number2
        {
          self.dataModel.number2 = val
        }
        self.dataModel.contextMgr.currentFocus = focus
      }
    } else {
      NSBeep()
    }
  }

  func toggleImageColor() {
    updateActionAndRefresh(owner: owner) {
      let color = dataModel.contextMgr.imageColor
      if color == NSColor.white {
        print("Switch color white to green")
        self.dataModel.contextMgr.imageColor = NSColor.green
      } else {
        print("Switch color green to white")
        self.dataModel.contextMgr.imageColor = NSColor.white
      }
    }
  }

  // MARK: - Get Data Model

  //MARK: getFocus
  static let getFocusKeypathSet =
    KeypathSet(readWithRoot: ContextMgr.contextMgrK, chain: [ContextMgr.currentFocusK])


  func getFocus() -> NSObject? {
    return dataModel.contextMgr.observed.currentFocus
  }

  //MARK: getValue2
  static let getValue2KeypathSet =
    KeypathSet(readWithRoot: DataModel.dataModelK, chain:[DataModel.number2K])

  func getValue2() -> String {
    let formatter = NumberFormatter()
    let val = self.dataModel.observedSelf.number2
    return  formatter.string(from: NSNumber(value: val)) ?? "Error"
  }


  //MARK: getSum
  static let getSumKeypathSet =
    KeypathSet(readWithRoot: DataModel.dataModelK, chain: [DataModel.sumOfNumberK])


  func getSum() -> Int?
  {
    let sum = self.dataModel.observedSelf.getSum()
    return sum
  }

  //MARK: getColor
  static let getColorKeypathSet =
    KeypathSet(readWithRoot: ContextMgr.contextMgrK, chain: [ContextMgr.imageColorK])

  func getColor() -> NSColor
  {
    return dataModel.contextMgr.observed.imageColor
  }
}
