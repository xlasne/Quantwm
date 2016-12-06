//
//  RepositoryObserver.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 18/04/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import Foundation


class RootNode {
  weak var changeCounter: ChangeCounter?
  weak var rootObject: MonitoredClass?
  let keypath : String

  init(rootObject: MonitoredClass, changeCounter: ChangeCounter, keypath : String)
  {
    self.rootObject = rootObject
    self.changeCounter = changeCounter
    self.keypath = keypath
  }
}

open class RepositoryObserver: NSObject {

  // Dictionary of the root nodes
  // Root nodes are the first component of keypath, the path anchor
  var rootDataDict: [String:RootNode] = [:]

  // Dictionary of KeypathObserver
  // KeypathObserver are monitoring a keypath, comparing old and new state from refresh to refresh
  var keypathObserverDict: [String:KeypathObserver] = [:]

  // Set of KeySetObserver
  // KeySetObserver is set of KeypathObserver + Target/Action
  // If a keypath is changed, refreshUI() will trigger the target/action
  var keySetObserverSet: Set<KeySetObserver> = []

  // Monitor data read and write during a transaction
  var dataUsage: DataUsage?
  let dataUsageId = UUID().uuidString

  // Track the transaction context
  fileprivate var dataContext: DataContext = DataContext()

  // If refreshUI() is called during a refresh transaction it is ignored
  // If refreshUI() is called during a Loading or Update transaction it postponned to the end of the transaction
  var callRefreshOnEmptyStack = false

  // MARK: - Registration - Public

  // MARK: Root Node Registration - Public

  // Register this node as a root node, which can be uniquely identified by its rootDescription.propKey
  // This node does not have to remember this monitoring
  // On node deletion, this registration will end
  // To unregister root, call, repositoryObserver.unregisterRootNode(property: PropertyDescription)
  open func registerRoot(associatedObject: MonitoredClass, changeCounter: ChangeCounter, rootDescription: PropertyDescription)
  {
    let rootNode = RootNode(rootObject: associatedObject,
                            changeCounter: changeCounter,
                            keypath: rootDescription.propKey)

    let keypath = rootNode.keypath
    if let existing = self.rootDataDict[keypath] {
      if rootNode.changeCounter == existing.changeCounter {
        print("Data Observer: register again Root \(keypath)")
      } else {
        print("Data Observer: register and update Root \(keypath) ")
      }
    } else {
      print("Data Observer: register and create Root \(keypath)")
    }
    self.rootDataDict[keypath] = rootNode
  }

  open func unregisterRootNode(_ property: PropertyDescription)
  {
    let keypath = property.propKey
    assert(property.isRoot,"RepositoryObserver: Calling unregisterRootNode with non root \(keypath)")
    if let _ = self.rootDataDict[keypath] {
      print("Data Observer: unregister Root \(keypath)")
    } else {
      print("Data Observer: Warning - unregister non-existing Root \(keypath)")
    }
    self.rootDataDict.removeValue(forKey: keypath)
  }

  open func rootForKey(_ property: PropertyDescription) -> MonitoredClass?
  {
    let keypath = property.propKey
    assert(property.isRoot,"RepositoryObserver: Calling rootForKey with non root \(keypath)")
    if let root = self.rootDataDict[keypath]?.rootObject {
      let changeCounter = root.getNodeChangeCounter()
      changeCounter.performedReadOnMainThread(property)
      return root
    }
    return nil
  }

  // MARK: ObserverSet Registration - Public

  open func registerForEachCycle(target: NSObject, selector: Selector, name: String,
                                          maximumAllowedRegistrationWithSameTypeSelector: Int? = nil)  {
    self.registerObserver(target: target, selector: selector, keypathDescriptionSet: [], name: name)
  }

  open func registerObserver(target: NSObject,
                              registrationDesc: RegisterDescription,
                              name: String? = nil)
  {
    guard let name = name ?? registrationDesc.name else {
      assert(false,"RegisterDescription: Name is not set in static or dynamic call")
      return
    }

    self.registerObserver(target: target,
                  selector: registrationDesc.selector,
                  keypathDescriptionSet: registrationDesc.keypathDescriptionSet,
                  name: name,
                  writtenPropertySet: registrationDesc.writtenPropertySet,
                  maximumAllowedRegistrationWithSameTypeSelector: registrationDesc.maximumAllowedRegistrationWithSameTypeSelector,
                  configurationPriority: registrationDesc.configurationPriority)
  }

  open func registerObserver(target: NSObject,
                              selector: Selector,
                              keypathDescriptionSet: Set<KeypathDescription>,
                              name: String,
                              writtenPropertySet: Set<PropertyDescription> = [],
                              maximumAllowedRegistrationWithSameTypeSelector: Int? = nil,
                              configurationPriority: Int? = nil)  {

    if dataContext.isRootRefresh {
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
        assert(false,"Error: The number of registration for the same (type,selector) exceed the configured \(maximumAllowedRegistrationWithSameTypeSelector) value")
      }
    } else {
      if sameTypeArray.count > 0 {
        print("Warning: multiple dataset registration for the same (type,selector). Check that object are not leaking or increment maximumAllowedRegistrationWithSameTypeSelector to the number of allowed instance or set maximumAllowedRegistrationWithSameTypeSelector = 0 to disable check")
      }
    }

    var keypathSet = Set<String>()
    var readLevel = 0
    var keypathWithMaxLevel: KeypathDescription? = nil
    for keypathDescription in keypathDescriptionSet {
      self.registerKeypathObserver(KeypathObserver(keypathDesc: keypathDescription))
      keypathSet.insert(keypathDescription.keypath)
      if keypathDescription.level > readLevel {
        readLevel = keypathDescription.level
        keypathWithMaxLevel = keypathDescription
      }
    }

    // Check Level
    writtenPropertySet.forEach() {
      (writeProperty: PropertyDescription) in
      let writeLevel = writeProperty.level
      if writeLevel <= readLevel {
        assert(false, "RepositoryObserver: Registration of \(name): The writeProperty \(writeProperty.description) has a level of \(writeLevel), which is not strictly greater than the readLevel \(readLevel) of keypath \(keypathWithMaxLevel?.keypath) and level\(keypathWithMaxLevel?.levelDescription)")
      }
    }

    let writtenPropertyDesc = Set(writtenPropertySet.map({$0.description}))

    let keySetObserver = KeySetObserver(target: target,
                                        selector: selector,
                                        keypathSet: keypathSet,
                                        name: name,
                                        schedulingLevel: readLevel,
                                        writtenPropertySet: writtenPropertyDesc,
                                        configurationSchedulingLevel: configurationPriority)

    self.keySetObserverSet.insert(keySetObserver)
  }

  open func unregisterDataSetWithTarget(_ target: NSObject, selector: Selector? = nil)
  {
    let unregisterArray = keySetObserverSet.filter({$0.matchesTarget(target, selector: selector)})
    keySetObserverSet.subtract(unregisterArray)
  }

  //MARK: Helper functions
  fileprivate func getDataSetArrayForTypeFromTarget(_ target: NSObject, selector: Selector) -> [KeySetObserver]
  {
    let dataSet = self.keySetObserverSet.filter({
      let mirror = Mirror(reflecting: target)
      return ($0.type == mirror.subjectType) && ($0.targetAction == selector)
    })
    return dataSet
  }

  fileprivate func getKeySetObserverArrayForTarget(_ target: NSObject, selector: Selector? = nil) -> [KeySetObserver]
  {
    return keySetObserverSet.filter({$0.matchesTarget(target, selector: selector)})
  }

  fileprivate func getKeySetObserverForTarget(_ target: NSObject, selector: Selector) -> KeySetObserver?
  {
    let dataSet = self.getKeySetObserverArrayForTarget(target, selector: selector)
    if dataSet.count > 1 {
      print("Error: KeySetObserver contains twice the same target / selector")
    }
    return dataSet.first
  }

  open func displayUsage(owner: NSObject) {
    let observerArray = self.getKeySetObserverArrayForTarget(owner)
    for observer in observerArray    // .filter({!$0.isValid()})
    {
      observer.displayUsage(keypathObserverDict)
    }
  }

  // MARK: Observer Registration - Private

  fileprivate func registerKeypathObserver(_ keypathObserver: KeypathObserver)
  {
    let keypath = keypathObserver.keypath
    if let _ = self.keypathObserverDict[keypath] {
      print("Data Observer: register again \(keypath)")
      return
    }
    print("Data Observer: register and create \(keypath)")
    self.keypathObserverDict[keypath] = keypathObserver
  }

  fileprivate func unregisterKeypathObserver(_ keypathObserver: KeypathObserver)
  {
    let keypath = keypathObserver.keypath
    if let _ = self.keypathObserverDict[keypath]
    {
      print("Data Observer: unregistering \(keypath)")
      keypathObserverDict[keypath] = nil
    } else {
      print("Data Observer: Error of unregistering changeCounter \(keypath) - data is not registered")
    }
  }
}

// MARK: - Refresh UI

extension RepositoryObserver
{

  public func refreshUI() {
    // Check Pre-conditions
    if dataContext.isRootRefresh {
      print("Info: Call of RefreshUI inside RefreshUI ignored")
      return
    }

    if !dataContext.isRefreshAllowed {
      callRefreshOnEmptyStack = true
      print("Info: Call of RefreshUI will be delayed on empty stack")
      return
    }

    print("Start RefreshUI")

    keySetObserverSet = Set(keySetObserverSet.filter({$0.isValid()}))


    if QUANTUM_MVVM_DEBUG {
      self.dataUsage = DataUsage.registerContext(self.dataContext, uuid: dataUsageId)
    }


    var modifiedDataSetNeedingRefreshArray : [KeySetObserver] = []
    modifiedDataSetNeedingRefreshArray = keySetObserverSet.filter({$0.isValid()})
    modifiedDataSetNeedingRefreshArray = keySetObserverSet.filter({$0.isConfigurationType})

    modifiedDataSetNeedingRefreshArray.sort {
      (k1:KeySetObserver, k2: KeySetObserver) -> Bool in
      if k1.configurationSchedulingLevel! == k2.configurationSchedulingLevel! {
        return k1.schedulingLevel < k2.schedulingLevel
      } else {
        return k1.configurationSchedulingLevel! < k2.configurationSchedulingLevel!
      }
    }

    // First, perform Update transaction on configuration Register
    if !modifiedDataSetNeedingRefreshArray.isEmpty
    {

      // push Update context
      let outerUpdateContext = RWContext(UpdateWithOwner: self)
      dataContext.pushContext(outerUpdateContext)

      while !modifiedDataSetNeedingRefreshArray.isEmpty
      {
        let keySetObserver = modifiedDataSetNeedingRefreshArray.removeFirst()

        if let target = keySetObserver.target {
          let updateContext = RWContext(UpdateWithOwner: target)
          dataContext.pushContext(updateContext)

          // Evaluate the keypathObserver associated to it
          // As any write are possible, readAndCompareChain must be redone for each
          for readKey in keySetObserver.keypathSet
          {
            if let keypathObserver = self.keypathObserverDict[readKey] {
              let rootKey = keypathObserver.keypathBase
              if let rootNode = rootDataDict[rootKey]
              {
                keypathObserver.readAndCompareChain(rootNode: rootNode)
              }
            }
          }
          keySetObserver.triggerIfDirty(dataUsage, dataDict: self.keypathObserverDict)
          dataContext.popContext(updateContext)
        }
      }
      dataContext.popContext(outerUpdateContext)
    }


    var evaluatedObservable: Set<String> = []

    // push Refresh context
    let refreshContext = RWContext(refreshOwner: self)
    dataContext.pushContext(refreshContext)

    modifiedDataSetNeedingRefreshArray = keySetObserverSet.filter({$0.isValid()})
    modifiedDataSetNeedingRefreshArray = keySetObserverSet.filter({!$0.isConfigurationType})

    modifiedDataSetNeedingRefreshArray.sort {
      (k1:KeySetObserver, k2: KeySetObserver) -> Bool in
      return k1.schedulingLevel < k2.schedulingLevel
    }

    // Then, perform Loading transaction on normal Registred

    while !modifiedDataSetNeedingRefreshArray.isEmpty
    {
      let keySetObserver = modifiedDataSetNeedingRefreshArray.removeFirst()

      if let target = keySetObserver.target {
        let roContext = RWContext(LoadingWithOwner: target)
        dataContext.pushContext(roContext)

        // Evaluate the keypathObserver associated to it
        for readKey in keySetObserver.keypathSet
        {
          if !evaluatedObservable.contains(readKey) {
            if let keypathObserver = self.keypathObserverDict[readKey] {
              let rootKey = keypathObserver.keypathBase
              if let rootNode = rootDataDict[rootKey]
              {
                keypathObserver.readAndCompareChain(rootNode: rootNode)
              }
            }
            evaluatedObservable.insert(readKey)
          }
        }
        keySetObserver.triggerIfDirty(dataUsage, dataDict: self.keypathObserverDict)

        dataContext.popContext(roContext)
      }

    }

    dataContext.popContext(refreshContext)

    for observer in keySetObserverSet.filter({!$0.isValid()})
    {
      observer.displayUsage(keypathObserverDict)
    }
    keySetObserverSet = Set(keySetObserverSet.filter({$0.isValid()}))

    if QUANTUM_MVVM_DEBUG {
      DataUsage.unregisterContext(uuid: dataUsageId)
      dataUsage = nil
    }

    // Remove observables which belong to no keySetObserver, and commit the rest
    var usedObservervable: Set<String> = []
    for observer in keySetObserverSet
    {
      for readKey in observer.keypathSet
      {
        usedObservervable.insert(readKey)
      }
    }

    for (key,observable) in keypathObserverDict {
      if usedObservervable.contains(key) {
        observable.commitUpdate()
      } else {
        self.unregisterKeypathObserver(observable)
      }
    }

    callRefreshOnEmptyStack = false
    print("List of active KeySetObserver: \(keySetObserverSet.map({$0.name}))")
    print("End of refreshUI")
  }

}

// MARK: - Transaction Management - Private

extension RepositoryObserver
{

  fileprivate func pushLoadingContext(_ owner: NSObject?) -> RWContext
  {
    let roContext = RWContext(LoadingWithOwner: owner)
    dataContext.pushContext(roContext)
    return roContext
  }

  fileprivate func pushUpdateContext(_ owner: NSObject?) -> RWContext
  {
    let updateContext = RWContext(UpdateWithOwner:owner)
    dataContext.pushContext(updateContext)
    return updateContext
  }

  fileprivate func popContext(_ rwContext: RWContext)
  {
    dataContext.popContext(rwContext)
    if dataContext.isStackEmpty && callRefreshOnEmptyStack {
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
    if !dataContext.isRootRefresh {
      print("updateActionIfPossibleElseDispatch scheduled immediately")
      let writeContext = self.pushUpdateContext(owner)
      escapingHandler()
      self.popContext(writeContext)
    } else {
      // Update is not allowed. Perform this update later on the main thread
      DispatchQueue.main.async {[weak self] _ in
        // Modifications are performed while on the main thread which serialize update
        print("updateActionIfPossibleElseDispatch dispatch begin")
        if let writeContext = self?.pushUpdateContext(owner)
        {
            escapingHandler()
            self?.popContext(writeContext)
        }
      }
    }
  }
}



