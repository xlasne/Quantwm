//
//  QWObserver.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 15/04/16.
//  Copyright © 2016 XL Software Solutions. => MIT License
//

import Foundation

class QWObserver: NSObject {

  //MARK: Init and update
  init(target: NSObject, registration: QWRegistration)
  {
    self.target = target
    self.type = Swift.type(of: target)
    self.unionReadDescription = []
    self.registration = registration
    super.init()
    //print("QWObserver: target \(name) type \(self.type) created with \(keypathSet)")

    if !target.responds(to: actionSelector) {
      assert(false,"Error \(target) does not respond to selector \(actionSelector)")
    }
  }

  // The target + Action: The method which will be called if dataset is dirty
  weak var target: NSObject?
  let type: Any.Type  // used to detect multiple registration with the same type + selector

  let registration: QWRegistration

  // The set of PropertyDescription which can be written during the action
  // And enable exception to the write interdiction

  fileprivate var actionSelector: Selector { return registration.selector }
  var observedPathSet: Set<QWPath> { return registration.readPathSet }
  var name: String { return registration.name }
  var schedulingPriority: Int? { return registration.schedulingPriority }

  // configurationSchedulingLevel defines if the QWObserver is of configuration type
  // and if not nil, its priority
  var isPrioritySchedulingType: Bool {
    return schedulingPriority != nil
  }

  // The set of keypath triggering this action
  // QWMediator builds and updates the pathStateManagerDict:[QWPath : QWPathTraceManager] indexed by keypath
  // This set define the scheduling level of the QWObserver

  // force dirty when TriggetDataSet is created or its keypathSet modified
  fileprivate var forcedDirty = DirtyState.created

  // Each QWPathTraceManager has a counter, which is incremented on each call of readAndCompareTrace()
  // for this QWPath.
  // QWMediator will call triggerIfDirty() for our KeypathObserver a unique time during the refresh phase
  // During triggerIfDirty, updateDirtyStatus() will compare the current and previously stored values of the counter of each QWPath, and trigger a dirty -> perform action if any change.
  // Dirty or not, the current counters are stored for the next refreshUI call.
  fileprivate var observedPathsCounter: [QWPath:Int] = [:]
  
  // Maintain the union of all the RW_Action which are actually read
  // in order to detect registration to unused actions
  // unionReadDescription is composed only of PropertyDescription which are the result of the comparison between
  // configured and actual RW_Action, based on their common node.
  fileprivate var unionReadDescription: Set<QWPropertyID>

  // Return true if the delegate is nil, meaning that the target has been deallocated
  // and that we must discard this QWObserver
  func isValid() -> Bool
  {
    return self.target != nil
  }
  
  // return true is target matches, and if selector matches. Nil matches all selectors
  func matchesTarget(_ target: NSObject, selector: Selector? = nil) -> Bool
  {
    if target == self.target {
      if let selector = selector {
        return selector == self.actionSelector
      } else {
        return true
      }
    }
    return false
  }

  // Check if the same (target Type, Selector) is registered several times.
  // Useful to detect View Controllers which are not properly released
  func matchesType(_ type: Any.Type, selector: Selector) -> Bool
  {
    return (self.type == type) && (actionSelector == selector)
  }

  // Called once during refresh
  fileprivate func updateDirtyStatus(_ dataDict: [QWPath:QWPathTraceManager]) ->  (isDirty:Bool, description: String) {
    var desc: String = ""
    var isDirty = false
    
    for keypath in observedPathSet
    {
      var currentChangeCount = -1
      if let dataValue = dataDict[keypath]
      {
        currentChangeCount = dataValue.updateCounter
      }
      if let previousVal = observedPathsCounter[keypath] {
        if previousVal != currentChangeCount {
          desc = keypath.keypath
          isDirty = true
        }
      }
      observedPathsCounter[keypath] = currentChangeCount
    }
    
    if forcedDirty.isDirty() {
      desc = forcedDirty.description
      forcedDirty = .normal
      isDirty = true
    }
    
    if isDirty {
      return (isDirty:true, description: desc)
    }
    
    if observedPathSet.isEmpty {
      return (isDirty:true, description: "Trigger at each cycle (empty keypath set)")
    }
    
    return (isDirty:false, description: "Not Dirty")
  }

  func triggerIfDirty(_ dataUsage: DataUsage?, dataDict: [QWPath:QWPathTraceManager])
  {
    // Let check this if target has been released since last removal.
    guard let target = target else {
      print("Warning: QWObserver \(name). Attempt to perform refresh with nil target")
      return
    }
    
    let checkDirty = self.updateDirtyStatus(dataDict)
    if  !checkDirty.isDirty {
      return
    }
    
    print("Refresh \(self.name) because \(checkDirty.description)")
    
    // Normally performAction() should only read from the current dataset.

    // dataUsage is only defined in debug
    if let dataUsage = dataUsage {
      callPerformSelectorWith(target: target,
                              dataUsage: dataUsage ,
                              dataDict: dataDict)
    } else {
      // Call the registered selector on the target
      target.perform(self.actionSelector)
    }
  }

  //MARK: - DirtyState. Used by Undo

  enum DirtyState {
    case normal
    case created
    case updated(description: String)

    var description: String {
      switch self {
      case .normal:            return ""
      case .created:           return "Created"
      case .updated(let desc): return desc
      }
    }

    func isDirty() -> Bool {
      switch self {
      case .normal: return false
      default:      return true
      }
    }
  }

  // MARK: - Data Usage functions

  func callPerformSelectorWith(target: NSObject,
                               dataUsage: DataUsage ,
                               dataDict: [QWPath:QWPathTraceManager])
  {
    // clearContext() clears the read and write actions, not the dirty flag
    // which is needed by other keySetObservers
    dataUsage.clearContext(target)

    // Read the reference set of actions associated to the pathStateManagers
    let nodeSet = self.readActionSet(dataDict)

    // Call the registered selector on the target
    target.perform(self.actionSelector)

    // Check consistency
    let readActionSet  = dataUsage.getReadQWPathTraceManagerSet(target)

    let commonPropertySet = commonProperties(actionSet1: readActionSet, actionSet2: nodeSet)
    unionReadDescription.formUnion(commonPropertySet)
    let writeActionSet = dataUsage.getWriteQWPathTraceManagerSet(target)
    let result = DataUsage.compareArrays(
      readAction: readActionSet, configuredReadAction: nodeSet,
      writeAction: writeActionSet, configuredWriteProperties: registration.writtenPropertySet,
      name: name)
    switch result {
    case .error_WriteDataSetNotEmpty(let delta):
      print("Error: \(name) performs a write of \(delta.map({$0.propDescription})) which is not part of the registered writtenProperty QWObserver. Consider manually adding these writtenProperty to the registered \(name) QWObserver")
      assert(false, "Error: \(name) performs a write of \(delta.map({$0.propDescription})) which is not part of the registered writtenProperty QWObserver. Consider manually adding these writtenProperty to the registered \(name) QWObserver")
    case .warning_ReadDataSetContainsMoreDataThanQWObserver(let delta):
      print("Warning: \(name) performs a read of \(delta.map({$0.propDescription})) which is not part of the registered QWObserver. Consider manually adding this keypath to the registered \(name) QWObserver")
      assert(false, "Warning: \(name) performs a read of \(delta.map({$0.propDescription})) which is not part of the registered QWObserver. Consider manually adding this keypath to the registered \(name) QWObserver")
    default:
      break
    }
  }


  fileprivate func readActionSet(_ dataDict: [QWPath:QWPathTraceManager]) ->  Set<RW_Action> {
    var result: Set<RW_Action> = []
    for keypath in observedPathSet
    {
      if let pathStateManager = dataDict[keypath]
      {
        let actionSet = pathStateManager.collectNodeSet()
        result.formUnion(actionSet)
      }
    }
    return result
  }

  func displayUsage(_ dataDict: [QWPath:QWPathTraceManager]) -> DataSetComparisonResult<QWPropertyID>
  {
    var configuredProperties: Set<QWPropertyID> = []
    for keypath in observedPathSet
    {
      if let dataValue = dataDict[keypath] {
        let dataDesc:Set<QWPropertyID> = dataValue.propertyDescriptionSet
        configuredProperties.formUnion(dataDesc)
      }
    }

    if unionReadDescription == configuredProperties {
      print("Data Usage: Info: \(name) matches exactly its QWObserver")
      return DataSetComparisonResult.identical
    }

    if unionReadDescription.isSubset(of: configuredProperties) {
      let delta = configuredProperties.subtracting(unionReadDescription)
      print("Data Usage: Info: Read of \(name) does not perform read of \(delta) which is part of the registered QWObserver. This is normal if these values are not read at each refresh cycle")
      return DataSetComparisonResult.info_ReadDataSetIsContainedIntoQWObserver(delta)
    }

    let delta = unionReadDescription.subtracting(configuredProperties)
    print("Data Usage: Warning: Read of \(name) performs a read of \(delta) which is not part of the registered QWObserver. Consider manually adding this keypath to the registered \(name) QWObserver")
    return DataSetComparisonResult.warning_ReadDataSetContainsMoreDataThanQWObserver(delta)
  }

  func commonProperties(actionSet1:Set<RW_Action>, actionSet2:Set<RW_Action>) -> Set<QWPropertyID>
  {
    var propertySet : [QWPropertyID] = []
    for action in actionSet1 {
      let commonActions = actionSet2
        .filter({ action.isEquivalentTo($0) })
        .map({$0.propertyDesc})
      propertySet.append(contentsOf: commonActions)
    }
    return Set(propertySet)
  }

}
