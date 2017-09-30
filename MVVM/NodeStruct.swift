//
//  NodeStruct.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 02/05/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

//TODO: Not used yet

import Foundation
import QuantwmOSX

struct NodeStruct: QWMonitoredNode, Codable {

  enum CodingKeys: String, CodingKey {
    case _intValue
  }

  func getNodeChangeCounter() -> QWChangeCounter {
    return changeCounter
  }
  
  let changeCounter = QWChangeCounter()

  static let intValueK = PropertyDescriptor(keypath: \NodeStruct.intValue, description: "intValue")
  
  fileprivate var _intValue: Int = 0
  var intValue: Int {
    get {
      self.qwRead(property: NodeStruct.intValueK)
      return _intValue
    }
    set {
      if (newValue != _intValue) {
        self.qwWrite(property: NodeStruct.intValueK)
        _intValue = newValue
      }
    }
  }
  
  init(val: Int)
  {
    _intValue = val
  }
}
