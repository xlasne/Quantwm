//
//  QWMonitoredNode.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 10/05/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

// Problem:

// Get Swift QWMonitoredNode from ObjectiveC NSObject parent
// Get Swift QWMonitoredNode from Swift QWMonitoredNode parent
// Get Swift Object Watcher from ObjectiveC parent
// Get Swift Object Watcher from Swift QWMonitoredNode parent

// Manage Swift child with protocol compliance
// ObjectiveC child with keyValue introspection

// Perform all the job from swift side

// On return:
// If Swift child, return QWMonitoredNode
// If Objective-C child, return NSObject

// Build NodeObserver hierarchy
// NodeObserver points toward QWChangeCounter objects (common to Swift and ObjectiveC)


import Foundation


public protocol MonitoredClass: class, QWMonitoredNode  // class is required only to have weak pointers to object
{
}

//
//public typealias MonitoredStruct = QWMonitoredNode

public protocol QWMonitoredNode //: SwiftKVC
{
  func getNodeChangeCounter() -> QWChangeCounter
}
public extension QWMonitoredNode {
  func qwWrite(property: PropertyDescriptor) {
    self.getNodeChangeCounter().performedWriteOnMainThread(property)
  }
  func qwRead(property: PropertyDescriptor) {
    self.getNodeChangeCounter().performedReadOnMainThread(property)
  }
}




