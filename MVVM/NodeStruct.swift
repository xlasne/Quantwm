//
//  NodeStruct.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 02/05/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import Foundation

struct NodeStruct: MonitoredStruct {

    let changeCounter = ChangeCounter()

    static let intValueK = PropertyDescriptor<NodeStruct,Int>.key("_intValue")
    private var _intValue: Int = 0
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
