//
//  NodeSwift.swift
//  QuantwmOSX
//
//  Created by Xavier on 07/07/2017.
//  Copyright © 2017 XL Software Solutions. All rights reserved.
//

import Foundation
import QuantwmOSX


class NodeSwift: MonitoredNode
{

    let changeCounter = QWChangeCounter()

    func getNodeChangeCounter() -> QWChangeCounter {
        return changeCounter
    }

    static let intValueK = PropertyDescriptor(keypath: \NodeSwift.intValue, description: "intValue")

    var _intValue: Int = 0
    var intValue: Int {
        get {
            self.changeCounter.performedReadOnMainThread(NodeSwift.intValueK)
            return _intValue
        }
        set {
            self.changeCounter.performedWriteOnMainThread(NodeSwift.intValueK)
            _intValue = newValue
        }
    }

    init(val: Int)
    {
        _intValue = val
    }

}


