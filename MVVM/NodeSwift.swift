//
//  NodeSwift.swift
//  QuantwmOSX
//
//  Created by Xavier on 07/07/2017.
//  Copyright © 2017 XL Software Solutions. All rights reserved.
//

import Foundation
import QuantwmOSX


class NodeSwift: QWMonitoredNode
{
  
  let changeCounter = QWChangeCounter()
  static let rootK = TransientClass.ArrayValueK

  func getNodeChangeCounter() -> QWChangeCounter {
    return changeCounter
  }
  
  static let intValueK = PropertyDescriptor(keypath: \NodeSwift.intValue, description: "intValue")
  static let IntValueK = NodeSwift.rootK.appending(NodeSwift.intValueK)

  var _intValue: Int = 0
  var intValue: Int {
    get {
      self.qwRead(property: NodeSwift.intValueK)
      return _intValue
    }
    set {
      self.qwWrite(property: NodeSwift.intValueK)
      _intValue = newValue
    }
  }
  
  init(val: Int)
  {
    _intValue = val
  }
  
}


