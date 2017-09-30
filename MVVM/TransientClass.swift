//
//  TransientClass.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 17/04/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import Cocoa
import QuantwmOSX

class TransientClass: QWMonitoredNode {
  func getNodeChangeCounter() -> QWChangeCounter {
    return changeCounter
  }

  let changeCounter = QWChangeCounter()
  static let rootK = DataModel.TransientClassK

  static let transientValP = PropertyDescriptor(keypath:\TransientClass.transientVal,
                                                description: "transientVal")
  static let TransientValK = TransientClass.rootK.appending(TransientClass.transientValP)

  var _transientVal = "Toto"
  var transientVal: String {
    get {
      self.qwRead(property: TransientClass.transientValP)
      return _transientVal
    }
    set {
      if (newValue != _transientVal) {
        self.qwWrite(property: TransientClass.transientValP)
        _transientVal = newValue
      }
    }
  }
  
  static let intValueP = PropertyDescriptor(keypath:\TransientClass.intValue,
                                            description: "intValue")
  static let IntValueK = TransientClass.rootK.appending(TransientClass.intValueP)

  var _intValue: Int = 0
  var intValue: Int {
    get {
      self.qwRead(property: TransientClass.intValueP)
      return _intValue
    }
    set {
      if (newValue != _intValue) {
        self.qwWrite(property: TransientClass.intValueP)
        _intValue = newValue
      }
    }
  }
  
  static let arrayValueP = PropertyDescription<TransientClass,NodeSwift>(
    keypath: \TransientClass.arrayVal,
    description: "arrayVal").descriptor()
  
  static let ArrayValueK = TransientClass.rootK.appending(TransientClass.arrayValueP)

  fileprivate var _arrayVal: [NodeSwift] = [NodeSwift(val: 1), NodeSwift(val: 3)]
  var arrayVal: [NodeSwift] {
    get {
      self.qwRead(property: TransientClass.arrayValueP)
      return _arrayVal
    }
    set {
      self.qwWrite(property: TransientClass.arrayValueP)
      _arrayVal = newValue
    }
  }
  
}
