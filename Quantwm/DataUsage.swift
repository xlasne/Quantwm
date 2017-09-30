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

public class RW_Action: Equatable, CustomStringConvertible, Hashable {
  weak var node: QWChangeCounter?
  let propertyDesc: String
  let nodeId: NodeId?
  
  init(node: QWChangeCounter, property: RootDescriptor)
  {
    self.node = node
    self.propertyDesc = property.propDescription
    self.nodeId = node.nodeId
  }
  
  init(node: QWChangeCounter, property: PropertyDescriptor)
  {
    self.node = node
    self.propertyDesc = property.propDescription
    self.nodeId = node.nodeId
  }
  
  init(emptyNodeWithProperty property: PropertyDescriptor)
  {
    self.node = nil
    self.propertyDesc = property.propDescription
    self.nodeId = nil
  }
  
  public var description: String {
    return propertyDesc
  }
  
  public var hashValue: Int {
    return propertyDesc.hashValue ^ Int(nodeId ?? 0)
  }
  
  func isEquivalentTo(_ action: RW_Action) -> Bool
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

public func ==(lhs: RW_Action, rhs: RW_Action) -> Bool
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
  
  static func registerContext(_ dataContext: DataContext, uuid: String) -> DataUsage
  {
    // Under the hypothesis that monitoring will occurs only inside the current thread
    // and during the execution of a single method
    // at the end of the event cycle, and as this is normally intended for debug,
    // I used threadDictionary to avoid having to register and unregister each node at start and
    // end of the refreshUI, + the risk of missing some used nodes.
    // and to avoid the singleton ...
    // The advantage over a singleton is that there is one instance per thread
    let currentThread = Thread.current
    let threadDictionary  = currentThread.threadDictionary
    if let _ = threadDictionary[quantumKey] {
      assert(false,"Error in DataUsage: Context has not been unregistered")
    }
    let dataUsage = DataUsage(dataContext: dataContext)
    let quantumUsage = QuantwmDataUsage(dataUsage: dataUsage, id: uuid)
    threadDictionary[quantumKey] = quantumUsage
    return dataUsage
  }
  
  static func unregisterContext(uuid: String)
  {
    let currentThread = Thread.current
    let threadDictionary  = currentThread.threadDictionary
    if let currentUsage = threadDictionary[quantumKey] as? QuantwmDataUsage {
      assert(currentUsage.id == uuid,"Error: Mismatch in DataUsage register")
      threadDictionary[quantumKey] = nil
    }
  }
  
  static func currentInstance() -> DataUsage?
  {
    let currentThread = Thread.current
    let threadDictionary  = currentThread.threadDictionary
    let currentUsage = threadDictionary[quantumKey] as? QuantwmDataUsage
    return currentUsage?.dataUsage
  }
  
  class ReadWriteSet {
    var writeSet: Set<RW_Action> = Set()
    var  readSet: Set<RW_Action> = Set()
  }
  
  let checkStack = true
  
  fileprivate var contextDict: [NSObject:ReadWriteSet] = [:]
  fileprivate unowned var dataContext: DataContext
  
  required init(dataContext: DataContext) {
    self.dataContext = dataContext
    super.init()
  }
  
  func clearAll() {
    contextDict = [:]
  }
  
  func clearContext(_ owner: NSObject) {
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
  
  func getReadWriteSetForOwner(_ owner: NSObject) -> ReadWriteSet
  {
    if let readWriteSet = contextDict[owner] {
      return readWriteSet
    } else {
      let readWriteSet = ReadWriteSet()
      contextDict[owner] = readWriteSet
      return readWriteSet
    }
  }
  
  func addRead(_ node: QWChangeCounter, property: PropertyDescriptor) {
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
  
  func addWrite(_ node: QWChangeCounter, property: PropertyDescriptor) {
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
  

  func getReadKeypathObserverSet(_ owner: NSObject?) -> Set<RW_Action> {
    if let owner = owner {
      guard let readWriteSet = contextDict[owner] else { return [] }
      return readWriteSet.readSet
    } else {
      let readWriteSet = contextDict
        .values
        .map({$0.readSet})
        .joined()
      return Set(readWriteSet)
    }
  }
  
  func getWriteKeypathObserverSet(_ owner: NSObject?) -> Set<RW_Action> {
    if let owner = owner {
      guard let readWriteSet = contextDict[owner] else { return [] }
      return readWriteSet.writeSet
    } else {
      let readWriteSet = contextDict
        .values
        .map({$0.writeSet})
        .joined()
      return Set(readWriteSet)
    }
  }
  
}

