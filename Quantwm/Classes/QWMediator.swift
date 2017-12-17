//
//  QWMediator.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 18/04/16.
//  Copyright © 2016 XL Software Solutions. => MIT License
//

import Foundation

final class QWRootHandle {
  weak var rootObject: QWRoot?
  let keypath : String
  
  init(rootObject: QWRoot, keypath : String)
  {
    self.rootObject = rootObject
    self.keypath = keypath
  }
}

public class QWMediator: NSObject {
  
  // Dictionary of the root nodes
  // TODO: Simplify QWMediator to only manage one Root
  // because ... QWMediator shall belong to this Root

  // Root nodes are the first component of keypath, the path anchor
  fileprivate var rootDataDict: [String:QWRootHandle] = [:]

  var dependencyMgr: QWDependencyMgr = QWDependencyMgr(registrationSet:[])

  // Root Node of the Model to be archived
  weak var modelRootNode: QWRoot?

  // Indicates that model shall be saved
  var modelUpdatedClosure: ((Bool)->())?

  var endOfRefreshOnceClosureArray:[(()->())] = []
  public func registerEndOfRefreshOnce(closure: @escaping (()->())) {
    endOfRefreshOnceClosureArray.append(closure)
  }

  // Commit Tag
  var currentCommit: String?

  // Model update monitoring regisration - perform check and undo storage
  // at end of each event loop where changes have been detected
  func registerModel(modelRootNode: QWRoot, modelUpdatedClosure: @escaping (Bool)->()) {
    self.modelRootNode = modelRootNode
    self.modelUpdatedClosure = modelUpdatedClosure
  }

  // Dictionary of QWPathTraceManager
  // QWPathTraceManager are monitoring a keypath, comparing old and new state from refresh to refresh
  // QWPathTraceManager is initialized with { root: QWRootProperty, chain: [QWProperty]}
  // QWPathTraceManager compute, store and compare difference of QWPathTraceReader
  // from QWRootHandle objects.
  var pathStateManagerDict: [QWPath:QWPathTraceManager] = [:]
  
  // Set of QWObserver
  // QWObserver is a Target/Action + a set of QWPathTraceManager
  // If a QWPathTraceManager detects a change, refreshUI() will trigger the registered target/action
  var observerSet: Set<QWObserver> = []
  
  // Monitor data read and write during a transaction
  var dataUsage: DataUsage?
  let dataUsageId = UUID().uuidString
  
  // Track the transaction context
  fileprivate var qwTransactionStack: QWTransactionStack = QWTransactionStack()
  
  // If refreshUI() is called during a Refresh transaction it is ignored
  // If refreshUI() is called during an Update transaction it postponned to the end of the transaction
  var refreshUICalledWhileContextStackWasNotEmpty = false
  
  // MARK: - Registration - Public
  
  // MARK: Root Node Registration - Public
  
  // Register this node as a root node, which can be uniquely identified by its rootDescription.propKey
  // This node does not have to remember this monitoring
  // On node deletion, this registration will end
  // To unregister root, call, qwMediator.unregisterRootNode(property: PropertyDescription)
  open func registerRoot(qwRoot: QWRoot, rootProperty: QWRootProperty)
  {
    let rootNode = QWRootHandle(rootObject: qwRoot,
                            keypath: rootProperty.rootId)
    
    let keypath = rootNode.keypath
    if let existing = self.rootDataDict[keypath] {
      if rootNode.rootObject === existing.rootObject {
        print("Data Observer: register again Root \(keypath)")
      } else {
        print("Data Observer: register and update Root \(keypath) ")
      }
    } else {
      print("Data Observer: register and create Root \(keypath)")
    }
    self.rootDataDict[keypath] = rootNode
    // No need to delete previous QWPathTrace.
    // The unicity of the QWCounter determines if the properties have changed.
  }
  
  open func unregisterRootNode(_ property: QWRootProperty)
  {
    let keypath = property.rootId
    if let _ = self.rootDataDict[keypath] {
      //print("Data Observer: unregister Root \(keypath)")
    } else {
      //print("Data Observer: Warning - unregister non-existing Root \(keypath)")
    }
    self.rootDataDict.removeValue(forKey: keypath)
  }
  
  open func rootForKey(_ property: QWRootProperty) -> QWRoot?
  {
    let keypath = property.rootId
    return self.rootDataDict[keypath]?.rootObject
  }
  
  // MARK: ObserverSet Registration - Public

  open  func registerObserver(target: NSObject,
                             registrationDesc reg: QWRegistration)
  {

    let selector = reg.selector
    let qwPathSet = reg.readPathSet
    let maximumAllowedRegistrationWithSameTypeSelector = reg.maximumAllowedRegistrationWithSameTypeSelector

    if qwTransactionStack.isRootRefresh {
      assert(false,"Error: Register shall not be performed inside a refresh UI call")
    }
    
    if let _ = self.getQWObserverForTarget(target, selector: selector)
    {
      print("Warning: multiple dataset registration for the same (target:\(target.description),selector:\(selector.description)). Use addMonitorData / removeMonitorData to modify a dataset, or delete it before with unregisterDataSetWithTarget")
      self.unregisterDataSetWithTarget(target, selector: selector)
    }
    
    let sameTypeArray = self.getDataSetArrayForTypeFromTarget(target, selector: selector)
    if let count = maximumAllowedRegistrationWithSameTypeSelector {
      if (count > 0) && (sameTypeArray.count > count-1) { // count-1 because we are not registered yet
        assert(false,"Error: The number of registration for the same (type,selector) exceed the configured \(String(describing: maximumAllowedRegistrationWithSameTypeSelector)) value")
      }
    } else {
      if sameTypeArray.count > 0 {
        print("Warning: multiple dataset registration for the same (\(target),\(selector)): \(qwPathSet). Check that object are not leaking or increment maximumAllowedRegistrationWithSameTypeSelector to the number of allowed instance or set maximumAllowedRegistrationWithSameTypeSelector = 0 to disable check")
      }
    }

    for qwPath in qwPathSet {
      self.registerPathTraceManager(QWPathTraceManager(qwPath: qwPath))
    }

    let keySetObserver = QWObserver(target: target,
                                        registration: reg)
    
    self.observerSet.insert(keySetObserver)

    self.dependencyMgr = QWDependencyMgr(
      registrationSet: Set(observerSet.map({$0.registration})))
  }
  
  open func unregisterDataSetWithTarget(_ target: NSObject, selector: Selector? = nil)
  {
    let unregisterArray = observerSet.filter({$0.matchesTarget(target, selector: selector)})
    observerSet.subtract(unregisterArray)
  }
  
  //MARK: Helper functions
  fileprivate func getDataSetArrayForTypeFromTarget(_ target: NSObject, selector: Selector) -> Set<QWObserver>
  {
    let mirrorType = Mirror(reflecting: target).subjectType
    let dataSet = self.observerSet.filter({$0.matchesType(mirrorType, selector: selector)})
    return Set(dataSet)
  }
  
  fileprivate func getQWObserverArrayForTarget(_ target: NSObject, selector: Selector? = nil) -> Set<QWObserver>
  {
    let keySetObserverArray = Array(observerSet).filter({$0.matchesTarget(target, selector: selector)})
    return Set(keySetObserverArray)
  }
  
  fileprivate func getQWObserverForTarget(_ target: NSObject, selector: Selector) -> QWObserver?
  {
    let dataSet = self.getQWObserverArrayForTarget(target, selector: selector)
    if dataSet.count > 1 {
      //print("Error: QWObserver contains twice the same target / selector")
    }
    return dataSet.first
  }
  
  open func displayUsage(owner: NSObject) {
        let observerArray = self.getQWObserverArrayForTarget(owner)
        for observer in observerArray    // .filter({!$0.isValid()})
        {
          let _ = observer.displayUsage(pathStateManagerDict)
        }
  }
  
  // MARK: Observer Registration - Private
  
  fileprivate func registerPathTraceManager(_ pathStateManager: QWPathTraceManager)
  {
    let keypath = pathStateManager.qwPath
    if let _ = self.pathStateManagerDict[keypath] {
      //print("Data Observer: register again \(keypath)")
      return
    }
    //print("Data Observer: register and create \(keypath)")
    self.pathStateManagerDict[keypath] = pathStateManager
  }
  
  fileprivate func unregisterPathTraceManager(_ pathStateManager: QWPathTraceManager)
  {
    let keypath = pathStateManager.qwPath
    if let _ = self.pathStateManagerDict[keypath]
    {
      //print("Data Observer: unregistering \(keypath)")
      pathStateManagerDict[keypath] = nil
    } else {
      //print("Data Observer: Error of unregistering qwCounter \(keypath) - data is not registered")
    }
  }
}

// MARK: - Refresh UI

extension QWMediator
{
  public var isUnderRefresh: Bool {
    return qwTransactionStack.isRootRefresh
  }

  public func refreshUI() {

    // MARK: Pre-condition Check

    if !Thread.isMainThread {
      assert(false, "Error: RefreshUI - Calling refreshUI from background thread is a severe error")
    }

    if qwTransactionStack.isRootRefresh {
      //print("Info: Call of RefreshUI inside RefreshUI ignored")
      return
    }
    
    if !qwTransactionStack.isRefreshAllowed {
      refreshUICalledWhileContextStackWasNotEmpty = true
      //print("Info: Call of RefreshUI will be delayed until context stack is empty")
      return
    }
    
    print("Start RefreshUI")

//    dependencyMgr.debugDescription()
//    print("Starting RefreshUI")

    // MARK: Cleanup

    // Remove observerSet whose target is deallocated
    observerSet = Set(observerSet.filter({$0.isValid()}))

    let currentRefreshTag = UUID().uuidString
    if QUANTUM_MVVM_DEBUG {
      self.dataUsage = QuantwmDataUsage.registerContext(self.qwTransactionStack, currentTag: currentRefreshTag)
      dataUsage?.monitoringIsActive = false
    }

    // MARK: Hard-coded Priority Scheduling

    // First perform scheduling of hard-coded priority registration
    var setOfObserversToNotify : [QWObserver] = []
    setOfObserversToNotify = observerSet.filter({$0.isPrioritySchedulingType})
    
    setOfObserversToNotify.sort {
      (k1:QWObserver, k2: QWObserver) -> Bool in
      return k1.schedulingPriority! < k2.schedulingPriority!
    }

    //TODO: Manage the inserting of new priorityScehduling registration
    // during Priority Scheduling (Smart Registrations are already managed)
    // and reject registrations to priority level higher than the current one.
    // -> Mark keySetObserver as processed and perform a while loop

    // First, perform Update transaction for priority Scheduling
    if !setOfObserversToNotify.isEmpty
    {
      // push Update context on root, avoiding refresh UI during configuration refresh
      let outerUpdateContext = RWContext(UpdateWithOwner: self)
      qwTransactionStack.pushContext(outerUpdateContext)
      
      while !setOfObserversToNotify.isEmpty
      {
        let processedObserver = setOfObserversToNotify.removeFirst()
        
        if let target = processedObserver.target {
          let updateContext = RWContext(UpdateWithOwner: target)
          qwTransactionStack.pushContext(updateContext)
          
          // Evaluate the pathStateManager associated to it
          // As any write are possible, readAndCompareTrace must be redone for each QWPath
          for readPath in processedObserver.observedPathSet
          {
            if let pathStateManager = self.pathStateManagerDict[readPath] {
              let rootKey = pathStateManager.keypathBase
              if let rootNode = rootDataDict[rootKey]?.rootObject
              {
                QWPathWalker.applyReadOnlyPathAccess(rootNode: rootNode,
                                                     tag: currentRefreshTag,
                                                     path: readPath)
                pathStateManager.readAndCompareTrace(rootNode: rootNode)
              } else {
                pathStateManager.clearTraceOnNilRootNode()
              }
            }
          }
          // triggerIfDirty is called once per RefreshUI
          // The registered action is performed if QWMap has changed
          // since last RefreshUI for this keySetObserver
          dataUsage?.monitoringIsActive = true
          processedObserver.triggerIfDirty(dataUsage, dataDict: self.pathStateManagerDict)
          dataUsage?.monitoringIsActive = false
          qwTransactionStack.popContext(updateContext)
        }
      }
      qwTransactionStack.popContext(outerUpdateContext)
    }

    // MARK: Prepare Smart Scheduling

    var alreadyCheckedPathSet: Set<QWPath> = []
    
    // then push Root Refresh context on the empty root stack
    let refreshContext = RWContext(refreshOwner: self)
    qwTransactionStack.pushContext(refreshContext)

    // mark the whole tree with No Access level
    for rootNode in rootDataDict.values.flatMap({$0.rootObject}) {
      QWPathWalker.applyNoAccessOnWholeTree(rootNode: rootNode, tag: currentRefreshTag)
    }

    qwTransactionStack.stackReadLevel = QWStackReadLevel(currentTag: currentRefreshTag, readLevel: 0)

    // Then perform scheduling of smart type registration only
    observerSet = observerSet.filter({$0.isValid()})

    // TODO: dependencyMgr level is currently computed at registration
    // Should be performed once, here, if new registrations have been performed

    setOfObserversToNotify = observerSet.filter({!$0.isPrioritySchedulingType})
        setOfObserversToNotify.sort {
      (k1:QWObserver, k2: QWObserver) -> Bool in
      return dependencyMgr.level(reg: k1.registration) < dependencyMgr.level(reg: k2.registration)
    }

    // MARK: Smart Scheduling

    while !setOfObserversToNotify.isEmpty
    {
      let processedObserver = setOfObserversToNotify.removeFirst()
      
      if let target = processedObserver.target {

        // Push Notification context on TransactionStack
        let roContext = RWContext(NotificationWithOwner: target)
        qwTransactionStack.pushContext(roContext)
        
        // Evaluate the pathStateManager associated to it
        for readPath in processedObserver.observedPathSet
        {
          // An alreadyCheckedPathSet shall not be modified by design until the next update phase.
          // By consequence, its evaluation can be skipped
          // If a write is performed on it during the refresh, this assumption is wrong, hence the assert
          if !alreadyCheckedPathSet.contains(readPath) {
            if let pathStateManager = self.pathStateManagerDict[readPath] {
              let rootKey = pathStateManager.keypathBase
              if let rootNode = rootDataDict[rootKey]?.rootObject
              {
                QWPathWalker.applyReadOnlyPathAccess(rootNode: rootNode,
                                                     tag: currentRefreshTag,
                                                     path: readPath)
                pathStateManager.readAndCompareTrace(rootNode: rootNode)
              } else {
                pathStateManager.clearTraceOnNilRootNode()
              }
            }
            alreadyCheckedPathSet.insert(readPath)
          }
        }
        for writePath in processedObserver.writtenPathSet {
          if let rootNode = rootDataDict[writePath.rootPath]?.rootObject
          {
            QWPathWalker.applyWritePathAccess(rootNode: rootNode,
                                              tag: currentRefreshTag,
                                              path: writePath)
          }
        }


        // triggerIfDirty is called once per RefreshUI
        // The registered action is performed if QWMap has changed
        // since last RefreshUI for this keySetObserver
        dataUsage?.monitoringIsActive = true
        processedObserver.triggerIfDirty(dataUsage, dataDict: self.pathStateManagerDict)
        dataUsage?.monitoringIsActive = false
        // Pop Notification context on TransactionStack
        qwTransactionStack.popContext(roContext)
      }
    }

    //MARK: End of Refresh completion

    // Pop Root Refresh Context on TransactionStack
    qwTransactionStack.popContext(refreshContext)

    // Observer observers whose target is released
    for observer in observerSet.filter({!$0.isValid()})
    {
      let _ = observer.displayUsage(pathStateManagerDict)
    }
    observerSet = Set(observerSet.filter({$0.isValid()}))

    // Stop Data Usage Monitoring
    if QUANTUM_MVVM_DEBUG {
      QuantwmDataUsage.unregisterContext(currentTag: currentRefreshTag)
      dataUsage = nil
    }

    // Remove readPath which belong to no keySetObserver, and commit the rest
    var usedObservervable: Set<QWPath> = []
    for observer in observerSet
    {
      for readPath in observer.observedPathSet
      {
        usedObservervable.insert(readPath)
      }
    }
    for (key,observable) in pathStateManagerDict {
      if usedObservervable.contains(key) {
        observable.commitUpdate()
      } else {
        self.unregisterPathTraceManager(observable)
      }
    }
    
    refreshUICalledWhileContextStackWasNotEmpty = false
    print("List of active QWObserver: \(observerSet.map({$0.name}))")
    print("End of refreshUI")

    // This is the end of the write.

    //MARK: End of Refresh Hooks

    // Refresh Shield: endOfRefreshOnceClosureArray is used to disable a refreshShield
    // protecting an Action emitter from receiving the refresh corresponding to his update
    for closure in endOfRefreshOnceClosureArray { closure() }
    endOfRefreshOnceClosureArray = []

    // Undo Management: Check if the model has been updated
    // and call Undo Manager if needed
    if let root = modelRootNode,
        let modelUpdatedClosure = modelUpdatedClosure {
      let tag = currentCommit ?? ""
      let isUpdated = QWTreeWalker.scanNodeTreeReduce(
        fromParent: root,
        initialResult: false,
        { (isUpdated, node) -> Bool in
          if isUpdated == true { return true }
          let nodeIsUpdated = node.getQWCounter().isUpdated(tag: tag)
          if nodeIsUpdated {
            print("IsUpdated: \(node.getQWCounter().nodeName): \(node.getQWCounter().state)")
          }
          return nodeIsUpdated
      })
      modelUpdatedClosure(isUpdated)

      // Commit the changes
      let commitTag = UUID().uuidString
      currentCommit = commitTag
      if let root = modelRootNode {
        QWTreeWalker.scanNodeTreeMap(fromParent: root, closure: { (node: QWNode) in
          node.getQWCounter().commit(tag: commitTag)
        })
      }
    }
  }


  public func isUpdated(parent: QWNode) -> Bool {
    let tag = currentCommit ?? ""
    let isUpdated = QWTreeWalker.scanNodeTreeReduce(
      fromParent: parent,
      initialResult: false,
      { (isUpdated, node) -> Bool in
        if isUpdated == true { return true }
        let nodeIsUpdated = node.getQWCounter().isUpdated(tag: tag)
        if nodeIsUpdated {
          print("IsUpdated: \(node.getQWCounter().nodeName): \(node.getQWCounter().state)")
//          print(" \(node.getQWCounter().changeCountDict)")
        }
        return nodeIsUpdated
    })
    print("Undo: isUpdated \(parent.getQWCounter().nodeName) = \(isUpdated)")
    return isUpdated
  }

}

// MARK: - UpdateActionAndRefresh Transaction Management

extension QWMediator
{

  public func updateActionAndRefresh(owner: NSObject?, handler: ()->())
  {
    let writeContext = self.pushUpdateContext(owner)
    handler()
    self.refreshUICalledWhileContextStackWasNotEmpty = true
    self.popContext(writeContext)
  }

  // The viewModelInputProcessinghandler shall do the Update access + RefreshUI
  public func updateActionAndRefreshSynchronouslyIfPossibleElseAsync(owner: NSObject?, escapingHandler: @escaping ()->())
  {
    if !qwTransactionStack.isRootRefresh {
      //print("updateActionAndRefreshSynchronouslyIfPossibleElseAsync scheduled immediately")
      updateActionAndRefresh(owner: owner, handler: escapingHandler)
    } else {
      // Update is not allowed. Perform this Action update asynchronously on the main thread
      DispatchQueue.main.async {[weak self]  in
        // Modifications are performed while on the main thread which serialize update
        //print("updateActionAndRefreshSynchronouslyIfPossibleElseAsync dispatch begin")
        self?.updateActionAndRefresh(owner: owner, handler: escapingHandler)
      }
    }
  }

  fileprivate func pushUpdateContext(_ owner: NSObject?) -> RWContext
  {
    let updateContext = RWContext(UpdateWithOwner:owner)
    // this is the first update on the stack
    // enable the model write
    if qwTransactionStack.isStackEmpty {
      let previousTag = currentCommit ?? ""
      if let root = modelRootNode {
        QWTreeWalker.scanNodeTreeMap(fromParent: root, closure: { (node: QWNode) in
          node.getQWCounter().allowUpdate(tag: previousTag)
        })
      }
    }

    qwTransactionStack.pushContext(updateContext)
    return updateContext
  }
  
  fileprivate func popContext(_ rwContext: RWContext)
  {
    qwTransactionStack.popContext(rwContext)
    if qwTransactionStack.isStackEmpty && refreshUICalledWhileContextStackWasNotEmpty {
      self.refreshUI()
    }
  }

}



