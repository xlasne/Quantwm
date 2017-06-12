//
//  TransientClass.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 17/04/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import Cocoa

class TransientClass: MonitoredNode {
    func getNodeChangeCounter() -> ChangeCounter {
        return changeCounter
    }


    let changeCounter = ChangeCounter()

    static let transientValK = PropertyDescriptor(keypath:\TransientClass.transientVal,
                                                  description: "transientVal")
    var _transientVal = "Toto"
    var transientVal: String {
        get {
            self.changeCounter.performedReadOnMainThread(TransientClass.transientValK)
            return _transientVal
        }
        set {
            if (newValue != _transientVal) {
                self.changeCounter.performedWriteOnMainThread(TransientClass.transientValK)
                _transientVal = newValue
            }
        }
    }

    static let intValueK = PropertyDescriptor(keypath:\TransientClass.intValue,
                                              description: "intValue")
    var _intValue: Int = 0
    var intValue: Int {
        get {
            self.changeCounter.performedReadOnMainThread(TransientClass.intValueK)
            return _intValue
        }
        set {
            if (newValue != _intValue) {
                self.changeCounter.performedWriteOnMainThread(TransientClass.intValueK)
                _intValue = newValue
            }
        }
    }

    static let arrayValueK = PropertyDescriptor(keypath:\TransientClass.arrayVal,
                                                description: "arrayVal")

    fileprivate var _arrayVal: [NodeObjc] = [NodeObjc(val: 1), NodeObjc(val: 3)]
    var arrayVal: [NodeObjc] {
        get {
            self.changeCounter.performedReadOnMainThread(TransientClass.arrayValueK)
            return _arrayVal
        }
        set {
            self.changeCounter.performedWriteOnMainThread(TransientClass.arrayValueK)
            _arrayVal = newValue
        }
    }

}
