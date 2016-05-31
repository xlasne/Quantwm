//
//  ChangeCounter.swift
//  QUANTWM
//
//  Created by Xavier on 15/04/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import Foundation

//MARK: - ChangeCounter
// Each monitored class or struct shall have a changeCounter property
// ChangeCounter increments the property counter each time the property is updated
// ChangeCounter checks that reads and writes are performed on Main Thread
// ChangeCounter also increments read or write dataUsage for debug monitoring

// Change watcher shall not be copied from an object to the other.
// If the object is copied, create a new changeCounter

typealias NodeId = Int32

public class ChangeCounter: NSObject {

    //MARK: Properties

    // Unique NodeId Generator
    static var nodeIdGenerator: NodeId = 0
    static func generateUniqueNodeId() -> NodeId {
        return OSAtomicIncrement32(&ChangeCounter.nodeIdGenerator)
    }

    // NodeId uniquely identify this node. Used by DataUsage
    let nodeId: NodeId  = ChangeCounter.generateUniqueNodeId()

    // Maintain a change counter for each value or reference property of its parent object/struct
    // Counter is created at 0 when requested
    var changeCountDict: [String:Int] = [:]

    //MARK: - Read / Write monitoring

public func performedReadOnMainThread(property: PropertyDescription)
    {
        let childKey = property.propKey
        if !NSThread.isMainThread() {
            assert(false, "Monitored Node: Error: reading from \(childKey) from background thread is a severe error")
        }
        if let dataUsage = DataUsage.currentInstance() {
            dataUsage.addRead(self, property: property)
        }
    }

public  func performedWriteOnMainThread(property: PropertyDescription)
    {
        let childKey = property.propKey
        if !NSThread.isMainThread() {
            assert(false, "Monitored Node: Error: writing from \(childKey) from background thread is a severe error")
        }
        self.setDirty(childKey)

        if let dataUsage = DataUsage.currentInstance() {
            dataUsage.addWrite(self, property: property)
        }
    }

    //MARK: - Update Property Management

    // Increment changeCount for a property
    func setDirty(childKey: String) -> Int
    {
        print("Monitoring Node: Child \(childKey) dirty")
        if let previousValue = self.changeCountDict[childKey] {
            self.changeCountDict[childKey] = previousValue + 1
            return previousValue + 1
        } else {
            self.changeCountDict[childKey] = 1
            return 1
        }
    }

    // Get current changeCount for a property
    func changeCount(childKey: String) -> Int
    {
        if let changeCount = self.changeCountDict[childKey] {
            return changeCount
        } else {
            self.changeCountDict[childKey] = 0
            return 0
        }
    }

}

