//
//  TransientClass.swift
//  QUANTWM
//
//  Created by Xavier on 17/04/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import Cocoa

class TransientClass: SwiftKVC, MonitoredNode {

    let changeCounter = ChangeCounter()

    let properties: [PropertyDescription] = [TransientClass.arrayValueK,
                                             TransientClass.intValueK,
                                             TransientClass.transientValK]
    
    static let transientValK = PropertyDescriptor<TransientClass,String>.key("_transientVal")
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

    static let intValueK = PropertyDescriptor<TransientClass,Int>.key("intValue")
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

    static let arrayValueK = PropertyDescriptor<TransientClass,NodeObjc>.key("_arrayVal",
            propertyDescriptionOption: [.ContainsNode, .ContainsCollection, .IsObjectiveC])
    private var _arrayVal: [NodeObjc] = [NodeObjc(val: 1), NodeObjc(val: 3)]
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
