//
//  DataUsage.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 15/04/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

// On refresh start, Observable are computed and parse the whole monitored data hierarchy to track updates.
// Before performing a given refresh based on a keySetObserver, the set of nodes contained in the Observables are registered in the currentDataUsage, to track mismatches.

let QUANTUM_MVVM_DEBUG = true

import Foundation

class RW_Action: Equatable, CustomStringConvertible, Hashable {
    weak var node: ChangeCounter?
    let propertyDesc: String
    let nodeId: NodeId?

    init(node: ChangeCounter, property: PropertyDescription)
    {
        self.node = node
        self.propertyDesc = property.description
        self.nodeId = node.nodeId
    }

    init(emptyNodeWithProperty property: PropertyDescription)
    {
        self.node = nil
        self.propertyDesc = property.description
        self.nodeId = nil
    }

    var description: String {
        return propertyDesc
    }

    var hashValue: Int {
        return propertyDesc.hashValue ^ Int(nodeId ?? 0)
    }

    func isEquivalentTo(action: RW_Action) -> Bool
    {
        // 2 RW_actions are equivalent if either 2 nodes are non nul and identical
        // or if one of them is nil
        if let id1 = self.nodeId,
            let id2 = action.nodeId {
            return id1 == id2 &&
                self.propertyDesc == action.propertyDesc
        }
        return self.propertyDesc == action.propertyDesc
    }
}

func ==(lhs: RW_Action, rhs: RW_Action) -> Bool
{
    return lhs.nodeId == rhs.nodeId && lhs.propertyDesc == rhs.propertyDesc
}

class DataUsage: NSObject
{

    class QuantwmDataUsage: NSObject {
        weak var dataUsage: DataUsage?
        let id: String
        init(dataUsage: DataUsage, id: String)
        {
            self.dataUsage = dataUsage
            self.id = id
            super.init()
        }
    }

    static let quantumKey = "QuantwmDataUsage"

    static func registerContext(dataContext: DataContext, uuid: String) -> DataUsage
    {
        // Under the hypothesis that monitoring will occurs only inside the current thread
        // and during the execution of a single method
        // at the end of the event cycle, and as this is normally intended for debug,
        // I used threadDictionary to avoid having to register and unregister each node at start and
        // end of the refreshUI, + the risk of missing some used nodes.
        // and to avoid the singleton ...
        // The advantage over a singleton is that there is one instance per thread
        let currentThread = NSThread.currentThread()
        let threadDictionary  = currentThread.threadDictionary
        if let _ = threadDictionary[quantumKey] {
            assert(false,"Error in DataUsage: Context has not been unregistered")
        }
        let dataUsage = DataUsage(dataContext: dataContext)
        let quantumUsage = QuantwmDataUsage(dataUsage: dataUsage, id: uuid)
        threadDictionary[quantumKey] = quantumUsage
        return dataUsage
    }

    static func unregisterContext(uuid uuid: String)
    {
        let currentThread = NSThread.currentThread()
        let threadDictionary  = currentThread.threadDictionary
        if let currentUsage = threadDictionary[quantumKey] as? QuantwmDataUsage {
            assert(currentUsage.id == uuid,"Error: Mismatch in DataUsage register")
            threadDictionary[quantumKey] = nil
        }
    }

    static func currentInstance() -> DataUsage?
    {
        let currentThread = NSThread.currentThread()
        let threadDictionary  = currentThread.threadDictionary
        let currentUsage = threadDictionary[quantumKey] as? QuantwmDataUsage
        return currentUsage?.dataUsage
    }

    class ReadWriteSet {
        var writeSet: Set<RW_Action> = Set()
        var  readSet: Set<RW_Action> = Set()
    }

    let checkStack = true

    private var contextDict: [NSObject:ReadWriteSet] = [:]
    private unowned var dataContext: DataContext

    required init(dataContext: DataContext) {
        self.dataContext = dataContext
        super.init()
    }

    func clearAll() {
        contextDict = [:]
    }

    func clearContext(owner: NSObject) {
        contextDict[owner] = nil
    }

    func display() {
        print(self.debugDescription)
    }

    override var debugDescription: String {
        get {
            return "ReadWrite \(contextDict)"
        }
    }

    func getReadWriteSetForOwner(owner: NSObject) -> ReadWriteSet
    {
        if let readWriteSet = contextDict[owner] {
            return readWriteSet
        } else {
            let readWriteSet = ReadWriteSet()
            contextDict[owner] = readWriteSet
            return readWriteSet
        }
    }

    func addRead(node: ChangeCounter, property: PropertyDescription) {
        let readAction = RW_Action(node: node, property: property)
        if checkStack {
            guard let lastContext = dataContext.rwContextStack.last else {
                assert(false,"Error: Trying to read while stack is empty")
                return
            }
            guard let owner = lastContext.owner else {
                assert(false,"Error: The context owner has been released")
                return
            }
            let readWriteSet = self.getReadWriteSetForOwner(owner)
            readWriteSet.readSet.insert(readAction)
        } else {
            let readWriteSet = self.getReadWriteSetForOwner(self)
            readWriteSet.readSet.insert(readAction)
        }
    }

    func addWrite(node: ChangeCounter, property: PropertyDescription) {
        let writeAction = RW_Action(node: node, property: property)
        if checkStack {
            guard let lastContext = dataContext.rwContextStack.last else {
                assert(false,"Error: Trying to write while stack is empty")
                return
            }
            guard let owner = lastContext.owner else {
                assert(false,"Error: The context owner has been released")
                return
            }
            let readWriteSet = self.getReadWriteSetForOwner(owner)
            readWriteSet.writeSet.insert(writeAction)
        } else {
            let readWriteSet = self.getReadWriteSetForOwner(self)
            readWriteSet.writeSet.insert(writeAction)
        }
    }
    
    // Return nil if and only if there is write performed
    // Else return read [KeypathObserver]
    func getMonitoredNodeReadArray(owner: NSObject) -> [RW_Action]?
    {
        guard let readWriteSet = contextDict[owner] else { return [] }
        if readWriteSet.writeSet.count > 0 {
            return nil
        }
        return Array(readWriteSet.readSet)
    }

    func getReadKeypathObserverSet(owner: NSObject?) -> Set<RW_Action> {
        if let owner = owner {
            guard let readWriteSet = contextDict[owner] else { return [] }
            return readWriteSet.readSet
        } else {
            let readWriteSet = contextDict
                .values
                .map({$0.readSet})
                .flatten()
            return Set(readWriteSet)
        }
    }

    func getWriteKeypathObserverSet(owner: NSObject?) -> Set<RW_Action> {
        if let owner = owner {
            guard let readWriteSet = contextDict[owner] else { return [] }
            return readWriteSet.writeSet
        } else {
            let readWriteSet = contextDict
                .values
                .map({$0.writeSet})
                .flatten()
            return Set(readWriteSet)
        }
    }

}

