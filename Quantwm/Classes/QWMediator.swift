//
//  QWMediator.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 18/04/16.
//  Copyright  MIT License
//

import Foundation

/// QWMediator shall be owned by NSApplication or NSDocument, in order to be
/// persistent in case of Data Model reload.
/// QWMediator manages a single Data Model, which must register itself with registerRoot()
open class QWMediator: NSObject {

  var rootDescriptor: QWPropertyID? = nil  // Set at first root registration
  // A Mediator is associated to a unique root type
  weak var rootObject: QWRoot? = nil

  var dependencyMgr: QWDependencyMgr = QWDependencyMgr(observerSet:[])

  var endOfRefreshOnceClosureArray:[(()->())] = []
  public func registerEndOfRefreshOnce(closure: @escaping (()->())) {
    endOfRefreshOnceClosureArray.append(closure)
  }

  // Commit Tag
  var currentCommit: String?

  // Undo Managment
  // Root Node of the Model to be archived
  weak var modelRootNode: QWRoot?

  // Indicates that model shall be saved
  var modelUpdatedClosure: ((Bool)->())?

  // Model update monitoring regisration - perform check and undo storage
  // at end of each event loop where changes have been detected
  func registerModel(modelRootNode: QWRoot, modelUpdatedClosure: @escaping (Bool)->()) {
    self.modelRootNode = modelRootNode
    self.modelUpdatedClosure = modelUpdatedClosure
  }


  // Dictionary of QWPathTraceManager
  // QWPathTraceManager are monitoring a keypath, comparing old and new state from refresh to refresh
  // QWPathTraceManager is initialized with { root: QWRootProperty, chain: [QWProperty]}
  // QWPathTraceManager compute, store and compare difference of QWPathTraceSnapshot
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
  open func registerRoot(model qwRoot: QWRoot, rootProperty: QWRootProperty)
  {
    if let rootDescriptor = self.rootDescriptor {
      if rootProperty.descriptor != rootDescriptor {
        assert(false,"Error QWMediator: Inconsistant rootProperty between on rootRegistration")
      }
    } else {
      self.rootDescriptor = rootProperty.descriptor
    }
    let rootDescription = rootProperty.descriptor.propDescription

    if let rootObject = self.rootObject {
      if rootObject === qwRoot {
        Swift.print("Data Observer: register again Root \(rootDescription)")
      } else {
        Swift.print("Data Observer: register and update Root \(rootDescription) ")
      }
    } else {
      Swift.print("Data Observer: register and create Root \(rootDescription)")
    }
    rootObject = qwRoot
    currentCommit = nil
    // No need to delete previous QWPathTrace.
    // The unicity of the QWCounter determines if the properties have changed.
  }

  public func getRoot() -> QWRoot? {
    return self.rootObject
  }
  
  open func unregisterRootNode(qwRoot: QWRoot)
  {
    if rootObject === qwRoot {
      rootObject = nil
    }
    if let rootDesc = rootDescriptor {
      Swift.print("Data Observer: unregister Root \(rootDesc.propDescription.description)")
    }
  }

  
  //MARK: Helper functions
  fileprivate func getObserverSetForName(_ name : String) -> Set<QWObserver>
  {
    let filteredObserverSet = observerSet.filter({$0.matchesName(name : name)})
    return filteredObserverSet
  }
  
  fileprivate func getObserverSetForTarget(_ target: AnyObject, name: String? = nil) -> Set<QWObserver>
  {
    let filteredObserverSet = observerSet.filter({$0.matchesTarget(target, name: name)})
    return filteredObserverSet
  }
  
  fileprivate func getObserverForTarget(_ target: AnyObject, name: String) -> QWObserver?
  {
    let dataSet = self.getObserverSetForTarget(target, name: name)
    return dataSet.first
  }
  
  open func displayUsage(owner: AnyObject) {
    let observerArray = self.getObserverSetForTarget(owner)
    for observer in observerArray    // .filter({!$0.isValid()})
    {
      observer.displayUsage()
    }
  }
  
  // MARK: Observer Registration - Private
  
  fileprivate func registerPathTraceManager(_ pathStateManager: QWPathTraceManager)
  {
    let keypath = pathStateManager.qwPath
    if let _ = self.pathStateManagerDict[keypath] {
      //Swift.print("Data Observer: register again \(keypath)")
      return
    }
    //Swift.print("Data Observer: register and create \(keypath)")
    self.pathStateManagerDict[keypath] = pathStateManager
  }
  
  fileprivate func unregisterPathTraceManager(_ pathStateManager: QWPathTraceManager)
  {
    let keypath = pathStateManager.qwPath
    if let _ = self.pathStateManagerDict[keypath]
    {
      //Swift.print("Data Observer: unregistering \(keypath)")
      pathStateManagerDict[keypath] = nil
    } else {
      //Swift.print("Data Observer: Error of unregistering qwCounter \(keypath) - data is not registered")
    }
  }

  // For asynchronous Refresh
  var currentObserverToken: QWObserverToken?
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
      //Swift.print("Info: Call of RefreshUI inside RefreshUI ignored")
      return
    }
    
    if !qwTransactionStack.isRefreshAllowed {
      refreshUICalledWhileContextStackWasNotEmpty = true
      //Swift.print("Info: Call of RefreshUI will be delayed until context stack is empty")
      return
    }

    guard let rootNode = rootObject else {
      Swift.print("Start RefreshUI cancelled: rootObject is nil")
      return
    }
    
    Swift.print("Start RefreshUI")

    // MARK: Cleanup

    // Remove observerSet whose target is deallocated
    observerSet = Set(observerSet.filter({$0.isValid()}))
    observerSet.forEach({ $0.hasBeenProcessed = false })

    let currentRefreshTag = UUID().uuidString
    var pathWalker:QWPathWalker? = nil
    if QWConfiguration.QUANTWM_DEBUG {
      self.dataUsage = QuantwmDataUsage.registerContext(self.qwTransactionStack, currentTag: currentRefreshTag)
      dataUsage?.disableMonitoring()
      pathWalker = QWPathWalker(root: rootNode, tag: currentRefreshTag)
    }

    // MARK: Hard-coded Priority Scheduling

    // First perform scheduling of hard-coded priority registration
    func getFirstHardcodedObserver(observerSet: Set<QWObserver>, priority: Int?) -> QWObserver? {
      var setOfObserversToNotify = Array(observerSet)
        .filter({$0.isPrioritySchedulingType})
        .filter({$0.hasBeenProcessed == false })
        .sorted {
          (k1:QWObserver, k2: QWObserver) -> Bool in
          return k1.schedulingPriority! < k2.schedulingPriority!
      }
      // New Registration with priority higher than current one are ignored
      if let priority = priority {
        setOfObserversToNotify = setOfObserversToNotify
          .filter({$0.schedulingPriority! >= priority })
      }
      return setOfObserversToNotify.first
    }

    // First, perform Update transaction for priority Scheduling
    // push Update context on root, avoiding refresh UI during configuration refresh
    let outerUpdateContext = RWContext(updateOwner: "QWMediator")
    qwTransactionStack.pushContext(outerUpdateContext)

    var currentPriority: Int? = nil
    while let processedObserver =  getFirstHardcodedObserver(observerSet: observerSet,
                                                             priority: currentPriority)
    {
      if let _ = processedObserver.target {
        let updateContext = RWContext(updateOwner: processedObserver.registration.name)
        qwTransactionStack.pushContext(updateContext)

        // Evaluate the pathStateManager associated to it
        // As any write are possible, readAndCompareTrace must be redone for each QWPath
        for readPath in processedObserver.observedPathSet
        {
          if let pathStateManager = self.pathStateManagerDict[readPath] {
            pathStateManager.readAndCompareTrace(rootNode: rootNode)
          }
        }
        // triggerIfDirty is called once per RefreshUI
        // The registered action is performed if QWMap has changed
        // since last RefreshUI for this keySetObserver

        // No Monitoring during hard scheduling
        dataUsage?.disableMonitoring()
        processedObserver.triggerIfDirty(dataUsage, dataDict: self.pathStateManagerDict)
        processedObserver.hasBeenProcessed = true
        currentPriority = processedObserver.schedulingPriority
        qwTransactionStack.popContext(updateContext)
      }
    }
    qwTransactionStack.popContext(outerUpdateContext)

    // MARK: Prepare Smart Scheduling

    var alreadyCheckedPathSet: Set<QWPath> = []
    
    // then push Root Refresh context on the empty root stack
    let refreshContext = RWContext(refreshOwner: "QWMediator")
    qwTransactionStack.pushContext(refreshContext)

    // mark the whole tree with No Access level
    pathWalker?.applyNoAccessOnWholeTree()

    qwTransactionStack.stackReadLevel = QWStackReadLevel(currentTag: currentRefreshTag, readLevel: 0)

    // Then perform scheduling of smart type registration only
    observerSet = observerSet.filter({$0.isValid()})

    // DependencyMgr computation shall be done here, once, if needed,
    // to include registrations added during hard-scheduling.
    if QWDependencyMgr.isDependencyRequired(observerSet: observerSet) {
      self.dependencyMgr = QWDependencyMgr(observerSet: observerSet)
    }

    var setOfObserversToNotify = Array(observerSet
      .filter({dependencyMgr.level(reg:$0.registration) != nil}))
      .sorted {
      (k1:QWObserver, k2: QWObserver) -> Bool in
      return dependencyMgr.level(reg: k1.registration)! < dependencyMgr.level(reg: k2.registration)!
    }

    // MARK: Smart Scheduling

    while !setOfObserversToNotify.isEmpty
    {
      let processedObserver = setOfObserversToNotify.removeFirst()
      
      if let _ = processedObserver.target {

        // Push Notification context on TransactionStack
        let roContext = RWContext(notificationOwner: processedObserver.registration.name,
                                  registrationUsage: processedObserver.registrationUsage)
        
        qwTransactionStack.pushContext(roContext)
        
        // Evaluate the pathStateManager associated to it
        for readPath in processedObserver.observedPathSet
        {
          // An alreadyCheckedPathSet shall not be modified by design until the next update phase.
          // By consequence, its evaluation can be skipped
          // If a write is performed on it during the refresh, this assumption is wrong, hence the assert
          if !alreadyCheckedPathSet.contains(readPath) {
            if let pathStateManager = self.pathStateManagerDict[readPath] {
              pathWalker?.applyReadOnlyPathAccess(path: readPath)
              pathStateManager.readAndCompareTrace(rootNode: rootNode)
            }
            alreadyCheckedPathSet.insert(readPath)
          }
        }
        for readPath in processedObserver.registration.collectorPathSet {
          pathWalker?.applyReadOnlyPathAccess(path: readPath)
        }
        for writePath in processedObserver.writtenPathSet {
          pathWalker?.applyWritePathAccess(path: writePath)
        }


        // triggerIfDirty is called once per RefreshUI
        // The registered action is performed if QWMap has changed
        // since last RefreshUI for this keySetObserver
        currentObserverToken = QWObserverToken(currentTag: currentRefreshTag, registrationUsage: processedObserver.registrationUsage)
        if processedObserver.alwaysTrigger {
          dataUsage?.activateWriteMonitoring()
        } else {
          dataUsage?.activateMonitoring()
        }
        processedObserver.triggerIfDirty(dataUsage, dataDict: self.pathStateManagerDict)
        dataUsage?.disableMonitoring()
        currentObserverToken = nil
        // Pop Notification context on TransactionStack
        qwTransactionStack.popContext(roContext)
      }
    }

    //MARK: End of Refresh completion

    // Pop Root Refresh Context on TransactionStack
    qwTransactionStack.popContext(refreshContext)

    // Observer observers whose target is released
    observerSet = Set(observerSet.filter({$0.isValid()}))

    // Stop Data Usage Monitoring
    if QWConfiguration.QUANTWM_DEBUG {
      QuantwmDataUsage.unregisterContext(currentTag: currentRefreshTag)
      dataUsage = nil
    }

    // Remove readPath which belong to no keySetObserver, and commit the rest
    var usedObservervable: Set<QWPath> = []
    for observer in observerSet
    {
      observer.hasBeenDirty = false
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
    Swift.print("List of active QWObserver: \(observerSet.map({$0.name}))")
    Swift.print("End of refreshUI")

    // This is the end of the write.

    //MARK: Hooks - End of Refresh

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
            Swift.print("IsUpdated: \(node.getQWCounter().nodeName): \(node.getQWCounter().state)")
          }
          return nodeIsUpdated
      })
      modelUpdatedClosure(isUpdated)
    }

    // Commit the changes
    let commitTag = UUID().uuidString
    currentCommit = commitTag
    if let root = modelRootNode {
      QWTreeWalker.scanNodeTreeMap(fromParent: root, closure: { (node: QWNode) in
        node.getQWCounter().commit(tag: commitTag)
      })
    }
  }


  // Used by Undo Management
  public func isUpdated(parent: QWNode) -> Bool {
    let tag = currentCommit ?? ""
    let isUpdated = QWTreeWalker.scanNodeTreeReduce(
      fromParent: parent,
      initialResult: false,
      { (isUpdated, node) -> Bool in
        if isUpdated == true { return true }
        let nodeIsUpdated = node.getQWCounter().isUpdated(tag: tag)
        if nodeIsUpdated {
          Swift.print("IsUpdated: \(node.getQWCounter().nodeName): \(node.getQWCounter().state)")
          //          Swift.print(" \(node.getQWCounter().changeCountDict)")
        }
        return nodeIsUpdated
    })
//    Swift.print("Undo: isUpdated \(parent.getQWCounter().nodeName) = \(isUpdated)")
    return isUpdated
  }

}

// MARK: - Registration
extension QWMediator
{

  // MARK: ObserverSet Registration - Public

  public func registerObserver(registration: QWRegistration,
                               target: NSObject,
                               selector: Selector,
                               maxNbRegistrationWithSameName: Int? = nil)
  {

    if !target.responds(to: selector) {
      assert(false,"Error \(target) does not respond to selector \(selector)")
    }

    let notificationClosure = { [weak target] () -> () in
      if let target = target {
        target.perform(selector)
      }
    }

    self.registerObserver(registration: registration,
                          target: target,
                          maxNbRegistrationWithSameName: maxNbRegistrationWithSameName,
                          notificationClosure: notificationClosure)
  }

  public func registerObserver(registration reg: QWRegistration,
                               target: AnyObject,
                               notificationClosure: @escaping () -> ()) {
    self.registerObserver(registration: reg,
                          target: target,
                          maxNbRegistrationWithSameName: nil,
                          notificationClosure: notificationClosure)
  }

  public func registerObserver(registration reg: QWRegistration,
                        target: AnyObject,
                        maxNbRegistrationWithSameName: Int?,
                        notificationClosure: @escaping () -> ())
  {
    let qwPathSet = reg.readPathSet

    if qwTransactionStack.isRootRefresh {
      assert(false,"Error: Register shall not be performed inside a refresh UI call")
    }

    if let _ = self.getObserverForTarget(target, name: reg.name)
    {
      Swift.print("Warning: multiple dataset registration for the same (target:\(target),name:\(reg.name)). Delete it before with unregisterRegistrationWithTarget")
      self.unregisterRegistrationWithTarget(target, name: reg.name)
    }

    let sameTypeArray = self.getObserverSetForName(reg.name)
    if let count = maxNbRegistrationWithSameName {
      if (count > 0) && (sameTypeArray.count > count-1) { // count-1 because we are not registered yet
        assert(false,"Error: The number of registration for the same (type,selector) exceed the configured \(String(describing: maxNbRegistrationWithSameName)) value")
      }
    } else {
      if sameTypeArray.count > 0 {
        Swift.print("Warning: multiple dataset registration for the same (target:\(target),name:\(reg.name)). Check that object are not leaking or increment maxNbRegistrationWithSameName to the number of allowed instance or set maxNbRegistrationWithSameName = 0 to disable check")
      }
    }

    for qwPath in qwPathSet {
      self.registerPathTraceManager(QWPathTraceManager(qwPath: qwPath))
    }

    let observer = QWObserver(target: target,
                              notificationClosure: notificationClosure,
                              registration: reg)

    self.observerSet.insert(observer)

  }

  public func unregisterRegistrationWithTarget(_ target: AnyObject, name: String? = nil)
  {
    let unregisterArray = observerSet.filter({$0.matchesTarget(target, name: name)})
    observerSet.subtract(unregisterArray)
  }

}

// MARK: - UpdateActionAndRefresh Transaction Management

extension QWMediator
{
  public func updateActionAndRefresh(owner: String, handler: ()->())
  {
    if !isUnderRefresh {
      let writeContext = self.pushUpdateContext(owner)
      handler()
      self.refreshUICalledWhileContextStackWasNotEmpty = true
      self.popContext(writeContext)
    }
    else {
      assert(false, "Warning: Trying to update during refresh")
    }
  }

  // The viewModelInputProcessinghandler shall do the Update access + RefreshUI
  public func updateActionAndRefreshSynchronouslyIfPossibleElseAsync(owner: String, escapingHandler: @escaping ()->())
  {
    if !qwTransactionStack.isRootRefresh {
      //Swift.print("updateActionAndRefreshSynchronouslyIfPossibleElseAsync scheduled immediately")
      updateActionAndRefresh(owner: owner, handler: escapingHandler)
    } else {
      // Update is not allowed. Perform this Action update asynchronously on the main thread
      DispatchQueue.main.async {[weak self]  in
        // Modifications are performed while on the main thread which serialize update
        //Swift.print("updateActionAndRefreshSynchronouslyIfPossibleElseAsync dispatch begin")
        self?.updateActionAndRefresh(owner: owner, handler: escapingHandler)
      }
    }
  }

  public func getCurrentObserverToken() -> QWObserverToken? {
    if QWConfiguration.QUANTWM_DEBUG {
      return currentObserverToken
    } else {
      return nil
    }
  }

  public func asynchronousRefresh<Value>(owner: String, token: QWObserverToken?, handler: ()->(Value)) -> Value
  {
    if let token = token,
      let registrationUsage = token.registrationUsage {
      self.dataUsage = QuantwmDataUsage.registerContext(self.qwTransactionStack, currentTag: token.currentTag)
      dataUsage?.disableMonitoring()

      let refreshContext = RWContext(refreshOwner: "QWMediator")
      qwTransactionStack.pushContext(refreshContext)
      
      let notificationContext = RWContext(notificationOwner: owner,
                                     registrationUsage: registrationUsage)
      qwTransactionStack.pushContext(notificationContext)
      if registrationUsage.registration.readPathSet.isEmpty {
        dataUsage?.activateWriteMonitoring()
      } else {
        dataUsage?.activateMonitoring()
      }
      registrationUsage.startCollecting()
      let value: Value = handler()
      registrationUsage.stopCollecting()
      dataUsage?.disableMonitoring()
      // Pop Notification context on TransactionStack
      qwTransactionStack.popContext(notificationContext)
      QuantwmDataUsage.unregisterContext(currentTag: token.currentTag)

      qwTransactionStack.popContext(refreshContext)
      dataUsage = nil
      return value
    } else {
      return handler()
    }
  }


  fileprivate func pushUpdateContext(_ owner: String) -> RWContext
  {
    let updateContext = RWContext(updateOwner:owner)
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

public struct QWObserverToken {
  let currentTag:String
  weak var registrationUsage: QWRegistrationUsage?

  public func displayUsage() {
    registrationUsage?.displayUsage()
  }
}


