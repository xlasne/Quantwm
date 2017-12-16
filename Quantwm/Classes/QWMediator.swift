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

  // Dictionary of QWPathTraceReader
  // QWPathTraceReader are monitoring a keypath, comparing old and new state from refresh to refresh
  // QWPathTraceReader is initialized with { root: QWRootProperty, chain: [QWProperty]}
  // QWPathTraceReader compute, store and compare difference of QWPathTraceProtocol
  // from QWRootHandle objects.
  var pathStateManagerDict: [QWPath:QWPathTraceReader] = [:]
  
  // Set of KeySetObserver
  // KeySetObserver is a Target/Action + a set of QWPathTraceReader
  // If a QWPathTraceReader detects a change, refreshUI() will trigger the registered target/action
  var keySetObserverSet: Set<KeySetObserver> = []
  
  // Monitor data read and write during a transaction
  var dataUsage: DataUsage?
  let dataUsageId = UUID().uuidString
  
  // Track the transaction context
  fileprivate var qwTransactionStack: QWTransactionStack = QWTransactionStack()
  
  // If refreshUI() is called during a refresh transaction it is ignored
  // If refreshUI() is called during a Loading or Update transaction it postponned to the end of the transaction
  var callRefreshOnEmptyStack = false
  
  // MARK: - Registration - Public
  
  // MARK: Root Node Registration - Public
  
  // Register this node as a root node, which can be uniquely identified by its rootDescription.propKey
  // This node does not have to remember this monitoring
  // On node deletion, this registration will end
  // To unregister root, call, qwMediator.unregisterRootNode(property: PropertyDescription)
  open func registerRoot(associatedObject: QWRoot, rootDescription: QWRootProperty)
  {
    let rootNode = QWRootHandle(rootObject: associatedObject,
                            keypath: rootDescription.propDescription)
    
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
    let keypath = property.propDescription
    if let _ = self.rootDataDict[keypath] {
      //print("Data Observer: unregister Root \(keypath)")
    } else {
      //print("Data Observer: Warning - unregister non-existing Root \(keypath)")
    }
    self.rootDataDict.removeValue(forKey: keypath)
  }
  
  open func rootForKey(_ property: QWRootProperty) -> QWRoot?
  {
    let keypath = property.propDescription
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
    
    if let _ = self.getKeySetObserverForTarget(target, selector: selector)
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
      self.registerQWPathTraceReader(QWPathTraceReader(qwPath: qwPath))
    }

    let keySetObserver = KeySetObserver(target: target,
                                        registration: reg)
    
    self.keySetObserverSet.insert(keySetObserver)

    self.dependencyMgr = QWDependencyMgr(
      registrationSet: Set(keySetObserverSet.map({$0.registration})))
  }
  
  open func unregisterDataSetWithTarget(_ target: NSObject, selector: Selector? = nil)
  {
    let unregisterArray = keySetObserverSet.filter({$0.matchesTarget(target, selector: selector)})
    keySetObserverSet.subtract(unregisterArray)
  }
  
  //MARK: Helper functions
  fileprivate func getDataSetArrayForTypeFromTarget(_ target: NSObject, selector: Selector) -> Set<KeySetObserver>
  {
    let dataSet = self.keySetObserverSet.filter({
      let mirror = Mirror(reflecting: target)
      return ($0.type == mirror.subjectType) && ($0.targetAction == selector)
    })
    return Set(dataSet)
  }
  
  fileprivate func getKeySetObserverArrayForTarget(_ target: NSObject, selector: Selector? = nil) -> Set<KeySetObserver>
  {
    let keySetObserverArray = Array(keySetObserverSet).filter({$0.matchesTarget(target, selector: selector)})
    return Set(keySetObserverArray)
  }
  
  fileprivate func getKeySetObserverForTarget(_ target: NSObject, selector: Selector) -> KeySetObserver?
  {
    let dataSet = self.getKeySetObserverArrayForTarget(target, selector: selector)
    if dataSet.count > 1 {
      //print("Error: KeySetObserver contains twice the same target / selector")
    }
    return dataSet.first
  }
  
  open func displayUsage(owner: NSObject) {
        let observerArray = self.getKeySetObserverArrayForTarget(owner)
        for observer in observerArray    // .filter({!$0.isValid()})
        {
          let _ = observer.displayUsage(pathStateManagerDict)
        }
  }
  
  // MARK: Observer Registration - Private
  
  fileprivate func registerQWPathTraceReader(_ pathStateManager: QWPathTraceReader)
  {
    let keypath = pathStateManager.qwPath
    if let _ = self.pathStateManagerDict[keypath] {
      //print("Data Observer: register again \(keypath)")
      return
    }
    //print("Data Observer: register and create \(keypath)")
    self.pathStateManagerDict[keypath] = pathStateManager
  }
  
  fileprivate func unregisterQWPathTraceReader(_ pathStateManager: QWPathTraceReader)
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
    // Check Pre-conditions
    if !Thread.isMainThread {
      assert(false, "Error: RefreshUI - Calling refreshUI from background thread is a severe error")
    }

    if qwTransactionStack.isRootRefresh {
      //print("Info: Call of RefreshUI inside RefreshUI ignored")
      return
    }
    
    if !qwTransactionStack.isRefreshAllowed {
      callRefreshOnEmptyStack = true
      //print("Info: Call of RefreshUI will be delayed on empty stack")
      return
    }
    
    print("Start RefreshUI")

//    dependencyMgr.debugDescription()
//    print("Starting RefreshUI")

    // Remove keySetObserverSet whose target is deallocated
    keySetObserverSet = Set(keySetObserverSet.filter({$0.isValid()}))

    if QUANTUM_MVVM_DEBUG {
      self.dataUsage = DataUsage.registerContext(self.qwTransactionStack, uuid: dataUsageId)
    }

    // First perform scheduling of configuration type registration
    var modifiedDataSetNeedingRefreshArray : [KeySetObserver] = []
    modifiedDataSetNeedingRefreshArray = keySetObserverSet.filter({$0.isConfigurationType})
    
    modifiedDataSetNeedingRefreshArray.sort {
      (k1:KeySetObserver, k2: KeySetObserver) -> Bool in
      return k1.configurationSchedulingLevel! < k2.configurationSchedulingLevel!
    }

    // First, perform Update transaction on configuration Register
    if !modifiedDataSetNeedingRefreshArray.isEmpty
    {
      // push Update context on root, avoiding refresh UI during configuration refresh
      let outerUpdateContext = RWContext(UpdateWithOwner: self)
      qwTransactionStack.pushContext(outerUpdateContext)
      
      while !modifiedDataSetNeedingRefreshArray.isEmpty
      {
        let keySetObserver = modifiedDataSetNeedingRefreshArray.removeFirst()
        
        if let target = keySetObserver.target {
          let updateContext = RWContext(UpdateWithOwner: target)
          qwTransactionStack.pushContext(updateContext)
          
          // Evaluate the pathStateManager associated to it
          // As any write are possible, readAndCompareTrace must be redone for each QWPath
          //
          for readKey in keySetObserver.observedQWMapDescriptionSet
          {
            if let pathStateManager = self.pathStateManagerDict[readKey] {
              let rootKey = pathStateManager.keypathBase
              if let rootNode = rootDataDict[rootKey]
              {
                pathStateManager.readAndCompareTrace(rootNode: rootNode)
              }
            }
          }
          // triggerIfDirty is called once per RefreshUI
          // The registered action is performed if QWMap has changed
          // since last RefreshUI for this keySetObserver
          keySetObserver.triggerIfDirty(dataUsage, dataDict: self.pathStateManagerDict)
          qwTransactionStack.popContext(updateContext)
        }
      }
      qwTransactionStack.popContext(outerUpdateContext)
    }
    
    var evaluatedObservable: Set<QWPath> = []
    
    // then push Refresh context on the empty root stack
    let refreshContext = RWContext(refreshOwner: self)
    qwTransactionStack.pushContext(refreshContext)

    // Then perform scheduling of normal type registration  ( configurationSchedulingLevel == nil )
    keySetObserverSet = keySetObserverSet.filter({$0.isValid()})
    modifiedDataSetNeedingRefreshArray = keySetObserverSet.filter({!$0.isConfigurationType})
    
    modifiedDataSetNeedingRefreshArray.sort {
      (k1:KeySetObserver, k2: KeySetObserver) -> Bool in
      return dependencyMgr.level(reg: k1.registration) < dependencyMgr.level(reg: k2.registration)
    }

    while !modifiedDataSetNeedingRefreshArray.isEmpty
    {
      let keySetObserver = modifiedDataSetNeedingRefreshArray.removeFirst()
      
      if let target = keySetObserver.target {
        let roContext = RWContext(NotificationWithOwner: target)
        qwTransactionStack.pushContext(roContext)
        
        // Evaluate the pathStateManager associated to it
        for readKey in keySetObserver.observedQWMapDescriptionSet
        {
          // An evaluatedObservable shall not be modified by design until the next update phase.
          // By consequence, its evaluation can be skipped
          // If a write is performed on it during the refresh, this assumption is wrong, hence the assert
          if !evaluatedObservable.contains(readKey) {
            if let pathStateManager = self.pathStateManagerDict[readKey] {
              let rootKey = pathStateManager.keypathBase
              if let rootNode = rootDataDict[rootKey]
              {
                pathStateManager.readAndCompareTrace(rootNode: rootNode)
              }
            }
            evaluatedObservable.insert(readKey)
          }
        }
        // triggerIfDirty is called once per RefreshUI
        // The registered action is performed if QWMap has changed
        // since last RefreshUI for this keySetObserver
        keySetObserver.triggerIfDirty(dataUsage, dataDict: self.pathStateManagerDict)
        qwTransactionStack.popContext(roContext)
      }
    }
    
    qwTransactionStack.popContext(refreshContext)

    for observer in keySetObserverSet.filter({!$0.isValid()})
    {
      let _ = observer.displayUsage(pathStateManagerDict)
    }
    keySetObserverSet = Set(keySetObserverSet.filter({$0.isValid()}))
    
    if QUANTUM_MVVM_DEBUG {
      DataUsage.unregisterContext(uuid: dataUsageId)
      dataUsage = nil
    }

    // Remove observables which belong to no keySetObserver, and commit the rest
    var usedObservervable: Set<QWPath> = []
    for observer in keySetObserverSet
    {
      for readKey in observer.observedQWMapDescriptionSet
      {
        usedObservervable.insert(readKey)
      }
    }
    
    for (key,observable) in pathStateManagerDict {
      if usedObservervable.contains(key) {
        observable.commitUpdate()
      } else {
        self.unregisterQWPathTraceReader(observable)
      }
    }
    
    callRefreshOnEmptyStack = false
    print("List of active KeySetObserver: \(keySetObserverSet.map({$0.name}))")
    print("End of refreshUI")

    // This is the end of the write.

    for closure in endOfRefreshOnceClosureArray { closure() }
    endOfRefreshOnceClosureArray = []

    // Check if the model has been updated
    if let root = modelRootNode {
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
      modelUpdatedClosure?(isUpdated)
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

// MARK: - Transaction Management - Private

extension QWMediator
{
  
  fileprivate func pushLoadingContext(_ owner: NSObject?) -> RWContext
  {
    let roContext = RWContext(NotificationWithOwner: owner)
    qwTransactionStack.pushContext(roContext)
    return roContext
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
    if qwTransactionStack.isStackEmpty && callRefreshOnEmptyStack {
      self.refreshUI()
    }
  }
  
  public func loadAction(owner: NSObject?, handler: ()->())
  {
    let loadContext = self.pushLoadingContext(owner)
    handler()
    self.popContext(loadContext)
  }
  
  public func loadActionWithReturn<T>(owner: NSObject?, handler: ()->(T)) -> T
  {
    let loadContext = self.pushLoadingContext(owner)
    defer { self.popContext(loadContext) } // will be called after handler execution ;)
    return handler()
  }
  
  public func updateAction(owner: NSObject?, handler: ()->())
  {
    let writeContext = self.pushUpdateContext(owner)
    handler()
    self.popContext(writeContext)
  }
  
  public func updateActionAndRefresh(owner: NSObject?, handler: ()->())
  {
    let writeContext = self.pushUpdateContext(owner)
    handler()
    self.callRefreshOnEmptyStack = true
    self.popContext(writeContext)
  }
  
  // The viewModelInputProcessinghandler shall do the Update access + RefreshUI
  public func updateActionIfPossibleElseDispatch(owner: NSObject?, escapingHandler: @escaping ()->())
  {
    if !qwTransactionStack.isRootRefresh {
      //print("updateActionIfPossibleElseDispatch scheduled immediately")
      let writeContext = self.pushUpdateContext(owner)
      escapingHandler()
      self.popContext(writeContext)
    } else {
      // Update is not allowed. Perform this update later on the main thread
      DispatchQueue.main.async {[weak self]  in
        // Modifications are performed while on the main thread which serialize update
        //print("updateActionIfPossibleElseDispatch dispatch begin")
        if let writeContext = self?.pushUpdateContext(owner)
        {
          escapingHandler()
          self?.popContext(writeContext)
        }
      }
    }
  }
}



