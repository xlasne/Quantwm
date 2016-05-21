//
//  ContextMgr.swift
//  MVVM
//
//  Created by Xavier on 08/04/16.
//  Copyright © 2016 XL Software Solutions
//

//KEYPOINT 5
// Responsible for consistent refresh of UI
// Manage view controllers dependency
// Send request to View Models, who triggers view controllers UI refresh when their matching view controller is present


import Foundation
import AppKit


class ContextMgr: NSObject, SwiftKVC, MonitoredObject
{
    // MARK: InterfacesMonitoredNode,
    static let contextMgrK = RootDescriptor<ContextMgr>.key("contextMgr")
    let changeCounter = ChangeCounter()
    var observed: ContextMgr {
        changeCounter.performedReadOnMainThread(ContextMgr.contextMgrK)
        return self
    }

    static let currentFocusK = PropertyDescriptor<ContextMgr,NSObject?>.key("_currentFocus")
    private var _currentFocus: NSObject? = nil
    var currentFocus: NSObject? {
        get {
            self.changeCounter.performedReadOnMainThread(ContextMgr.currentFocusK)
            return _currentFocus
        }
        set {
            self.changeCounter.performedWriteOnMainThread(ContextMgr.currentFocusK)
            _currentFocus = newValue
            print("Focus has been changed")
        }
    }

    static let _leftViewPresentK = PropertyDescriptor<ContextMgr,Bool>.key("_leftViewPresent")
    private var _leftViewPresent = true
    var leftViewPresent: Bool {
        get {
            self.changeCounter.performedReadOnMainThread(ContextMgr._leftViewPresentK)
            return _leftViewPresent
        }
        set {
            self.changeCounter.performedWriteOnMainThread(ContextMgr._leftViewPresentK)
            _leftViewPresent = newValue
        }
    }

    static let _rightViewPresentK = PropertyDescriptor<ContextMgr,Bool>.key("_rightViewPresent")
    private var _rightViewPresent = true
    var rightViewPresent: Bool {
        get {
            self.changeCounter.performedReadOnMainThread(ContextMgr._rightViewPresentK)
            return _rightViewPresent
        }
        set {
            self.changeCounter.performedWriteOnMainThread(ContextMgr._rightViewPresentK)
            _rightViewPresent = newValue
        }
    }

    static let _imageColorK = PropertyDescriptor<ContextMgr,NSColor>.key("_imageColor")
    private var _imageColor: NSColor = NSColor.whiteColor()
    var imageColor: NSColor {
        get {
            self.changeCounter.performedReadOnMainThread(ContextMgr._imageColorK)
            return _imageColor
        }
        set {
            self.changeCounter.performedWriteOnMainThread(ContextMgr._imageColorK)
            _imageColor = newValue
        }
    }

    init(dataModel: DataModel)
    {
        super.init()
        dataModel.dataRepositoryObserver.registerRoot(
            associatedObject: self,
            changeCounter: self.changeCounter,
            rootDescription: ContextMgr.contextMgrK)
    }
    
    func toggleLeftView()
    {
        leftViewPresent = !leftViewPresent
    }

    func toggleRightView()
    {
        rightViewPresent = !rightViewPresent
    }

    // For Monitoring<> example
    func getFocus()-> NSObject? { return currentFocus }
    func setFocus(focus: NSObject?) { currentFocus = focus }

}

