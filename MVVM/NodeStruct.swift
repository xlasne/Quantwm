//
//  NodeStruct.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 02/05/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import Foundation
import QuantwmOSX

struct NodeStruct: MonitoredNode {
    
    func getNodeChangeCounter() -> ChangeCounter {
        return changeCounter
    }

  let changeCounter = ChangeCounter()

  static let intValueK = PropertyDescriptor(keypath: \NodeStruct.intValue, description: "intValue")

    fileprivate var _intValue: Int = 0
  var intValue: Int {
    get {
      self.changeCounter.performedReadOnMainThread(NodeStruct.intValueK)
      return _intValue
    }
    set {
      if (newValue != _intValue) {
        self.changeCounter.performedWriteOnMainThread(NodeStruct.intValueK)
        _intValue = newValue
      }
    }
  }

  init(val: Int)
  {
    _intValue = val
  }
}
