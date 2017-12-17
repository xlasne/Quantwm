//
//  DataUsage.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 15/04/16.
//  Copyright © 2016 XL Software Solutions. => MIT License
//

// On refresh start, Observable are computed and parse the whole monitored data hierarchy to track updates.
// Before performing a given refresh based on a keySetObserver, the set of nodes contained in the Observables are registered in the currentDataUsage, to track mismatches.

// DataUsage is a global spy which is monitoring the reads and writes on any monitored property,
// belonging or not to the current refresh action.
// DataUsage is only active during the "perform Action" step of the RefreshUI
// DataUsage is only activated in Debug mode (QUANTUM_MVVM_DEBUG = true)
//
// When any monitored property is read or written, DataUsage check the RWContextStack to find which
// target is performing the current refresh action, and then add this RWAction in the contextDict for this owner.
// The problem in registering these read and write is that RefreshUI calls are recursively nested.
// The monitored usage is allocated to the most inner target.

//#if DEBUG
let QUANTUM_MVVM_DEBUG = true
//#else
//let QUANTUM_MVVM_DEBUG = false
//#endif

import Foundation


public class RW_Action: Equatable, CustomStringConvertible, Hashable {
  let nodeId: NodeId?
  let propertyDesc: QWPropertyID

  init(nodeId: NodeId?, property: QWPropertyID)
  {
    self.nodeId = nodeId
    self.propertyDesc = property
  }
  
  public var description: String {
    return propertyDesc.propDescription
  }
  
  public var hashValue: Int {
    return propertyDesc.hashValue ^ Int(nodeId ?? 0)
  }
  
  func isEquivalentTo(_ action: RW_Action) -> Bool
  {
    // A same property can be read either as a source or a destination
    // Hence 2 nodes are associated to it: the source node or the destination node
    //TODO: Manage the 2 cases. For the moment, just look at the description.
    return self.propertyDesc == action.propertyDesc
  }
}

public func ==(lhs: RW_Action, rhs: RW_Action) -> Bool
{
  return lhs.nodeId == rhs.nodeId && lhs.propertyDesc == rhs.propertyDesc
}


class QuantwmDataUsage: NSObject {

  // QuantwmDataUsage is owned by the thread Dictionary
  // and pointing to dataUsage.
  // dataUsage is owned by the QWMediator
  // QuantwmDataUsage is registered and unregistered by QWMediator
  weak var dataUsage: DataUsage?
  let id: String
  init(dataUsage: DataUsage, id: String)
  {
    self.dataUsage = dataUsage
    self.id = id
    super.init()
  }

  static let quantumKey = "QuantwmDataUsage"

  static func registerContext(_ qwTransactionStack: QWTransactionStack, currentTag: String) -> DataUsage
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
    let dataUsage = DataUsage(qwTransactionStack: qwTransactionStack, currentTag: currentTag)
    let quantumUsage = QuantwmDataUsage(dataUsage: dataUsage, id: currentTag)
    threadDictionary[quantumKey] = quantumUsage
    return dataUsage
  }

  static func unregisterContext(currentTag: String)
  {
    let currentThread = Thread.current
    let threadDictionary  = currentThread.threadDictionary
    if let currentUsage = threadDictionary[quantumKey] as? QuantwmDataUsage {
      assert(currentUsage.id == currentTag,"Error: Mismatch in DataUsage register")
      threadDictionary[quantumKey] = nil
    }
  }
}

class DataUsage: NSObject
{
  static func currentInstance() -> DataUsage?
  {
    let currentThread = Thread.current
    let threadDictionary  = currentThread.threadDictionary
    let currentUsage = threadDictionary[QuantwmDataUsage.quantumKey] as? QuantwmDataUsage
    return currentUsage?.dataUsage
  }
  
  let checkStack = true
  let currentTag: String

  // monitoringIsActive is activated during call of Notifications,
  // not when QWMediator scan the paths
  var monitoringIsActive: Bool = false

  fileprivate unowned var qwTransactionStack: QWTransactionStack
  
  required init(qwTransactionStack: QWTransactionStack, currentTag: String) {
    self.qwTransactionStack = qwTransactionStack
    self.currentTag = currentTag
    super.init()
  }

  func addRead(_ node: QWCounter, property: QWPropertyID) {
    if checkStack {
      guard let lastContext = qwTransactionStack.rwContextStack.last else {
        assert(false,"Error: Trying to read while stack is empty")
        return
      }
      if let registrationUsage = lastContext.registrationUsage {
        let readAction = RW_Action(nodeId: node.nodeId, property: property)
        registrationUsage.addReadAction(readAction: readAction)
      }
    }
  }
  
  func addWrite(_ node: QWCounter, property: QWPropertyID) {
    if checkStack {
      guard let lastContext = qwTransactionStack.rwContextStack.last else {
        assert(false,"Error: Trying to write while stack is empty")
        return
      }
      if let registrationUsage = lastContext.registrationUsage {
        let writeAction = RW_Action(nodeId: node.nodeId, property: property)
        registrationUsage.addWriteAction(writeAction: writeAction)
      }
    }
  }
}

