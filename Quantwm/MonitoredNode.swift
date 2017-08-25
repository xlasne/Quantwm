//
//  MonitoredNode.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 10/05/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

// Problem:

// Get Swift MonitoredNode from ObjectiveC NSObject parent
// Get Swift MonitoredNode from Swift MonitoredNode parent
// Get Swift Object Watcher from ObjectiveC parent
// Get Swift Object Watcher from Swift MonitoredNode parent

// Manage Swift child with protocol compliance
// ObjectiveC child with keyValue introspection

// Perform all the job from swift side

// On return:
// If Swift child, return MonitoredNode
// If Objective-C child, return NSObject

// Build NodeObserver hierarchy
// NodeObserver points toward ChangeCounter objects (common to Swift and ObjectiveC)


import Foundation


public protocol MonitoredClass: class, MonitoredNode  // class is required only to have weak pointers to object
{
}

//
//public typealias MonitoredStruct = MonitoredNode

public protocol MonitoredNode //: SwiftKVC
{
  func getNodeChangeCounter() -> ChangeCounter
}


