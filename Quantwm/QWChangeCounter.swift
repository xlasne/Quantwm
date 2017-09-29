//
//  QWChangeCounter.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 15/04/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import Foundation

//MARK: - QWChangeCounter
// Each monitored class or struct shall have a changeCounter property
// QWChangeCounter increments the property counter each time the property is updated
// QWChangeCounter checks that reads and writes are performed on Main Thread
// QWChangeCounter also increments read or write dataUsage for debug monitoring

// Change watcher shall not be copied from an object to the other.
// If the object is copied, create a new changeCounter

typealias NodeId = Int32

open class QWChangeCounter: NSObject {
  
  //MARK: Properties
  
  // Unique NodeId Generator
  static var nodeIdGenerator: NodeId = 0
  static func generateUniqueNodeId() -> NodeId {
    return OSAtomicIncrement32(&QWChangeCounter.nodeIdGenerator)
  }
  
  // NodeId uniquely identify this node. Used by DataUsage
  let nodeId: NodeId  = QWChangeCounter.generateUniqueNodeId()
  
  // Maintain a change counter for each value or reference property of its parent object/struct
  // Counter is created at 0 when requested
  var changeCountDict: [AnyKeyPath:Int] = [:]
  
  //MARK: - Read / Write monitoring
  
  func performedReadOnMainThread(_ property: PropertyDescriptor)
  {
    let childKey = property
    if !Thread.isMainThread {
      assert(false, "Monitored Node: Error: reading from \(childKey) from background thread is a severe error")
    }
    if let dataUsage = DataUsage.currentInstance() {
      dataUsage.addRead(self, property: property)
    }
  }
  
  func performedWriteOnMainThread(_ property: PropertyDescriptor)
  {
    let childKey = property.propKey
    if !Thread.isMainThread {
      assert(false, "Monitored Node: Error: writing from \(childKey) from background thread is a severe error")
    }
    self.setDirty(property)
    
    if let dataUsage = DataUsage.currentInstance() {
      dataUsage.addWrite(self, property: property)
    }
  }
  
  //MARK: - Update Property Management
  
  // Increment changeCount for a property
  func setDirty(_ property: PropertyDescriptor)
  {
    print("Monitoring Node: Child \(property.propDescription) dirty")
    if let previousValue = self.changeCountDict[property.propKey] {
      self.changeCountDict[property.propKey] = previousValue + 1
    } else {
      self.changeCountDict[property.propKey] = 1
    }
  }
  
  // Get current changeCount for a property
  func changeCount(_ property: PropertyDescriptor) -> Int
  {
    if let changeCount = self.changeCountDict[property.propKey] {
      return changeCount
    } else {
      self.changeCountDict[property.propKey] = 0
      return 0
    }
  }
  
}

