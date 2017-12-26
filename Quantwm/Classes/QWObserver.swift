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
  init(target: AnyObject, notificationClosure: @escaping ()->(), registration: QWRegistration)
  {
    self.target = target
    self.type = Swift.type(of: target)
    self.registration = registration
    self.notificationClosure = notificationClosure

    switch registration.registrationType {
    case .AlwaysTrigger:
      self.registrationUsage = QWRegistrationUsage(registration: registration)
    case .Collector:
      self.registrationUsage = QWRegistrationUsage(registration: registration)
    case .SmartScheduling:
      self.registrationUsage = QWRegistrationUsage(registration: registration)
    case .HardScheduling:
      self.registrationUsage = nil
    }

    super.init()
    print("QWObserver: R(\(registration.readPathSet.count)) W(\(registration.writtenPathSet.count)) target \(name) type \(self.type).")

  }

  // The target + Action: The method which will be called if dataset is dirty
//  weak var target: NSObject?
  let type: Any.Type  // used to detect multiple registration with the same type + selector

  let registration: QWRegistration

  var registrationUsage: QWRegistrationUsage?

  weak var target: AnyObject?
  var notificationClosure: () -> ()

  // The set of PropertyDescription which can be written during the action
  // And enable exception to the write interdiction

  var observedPathSet: Set<QWPath> { return registration.readPathSet }
  var writtenPathSet: Set<QWPath> { return registration.writtenPathSet }
  var name: String { return registration.name }
  var schedulingPriority: Int? { return registration.schedulingPriority }

  // configurationSchedulingLevel defines if the QWObserver is of configuration type
  // and if not nil, its priority
  var isPrioritySchedulingType: Bool {
    return schedulingPriority != nil
  }

  var alwaysTrigger: Bool {
    return observedPathSet.isEmpty
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
  
  // Return true if the delegate is nil, meaning that the target has been deallocated
  // and that we must discard this QWObserver
  func isValid() -> Bool
  {
    return self.target != nil
  }
  
  // return true is target matches, and if selector matches. Nil matches all selectors
  func matchesTarget(_ target: AnyObject, name: String?) -> Bool
  {
    if target === self.target {
      if let name = name {
        return name == self.name
      } else {
        return true
      }
    }
    return false
  }

  // Check if the same (target Type, Selector) is registered several times.
  // Useful to detect View Controllers which are not properly released
  func matchesName(name: String) -> Bool
  {
    return (self.name == name)
  }

  // Called once during refresh
  fileprivate func updateDirtyStatus(_ dataDict: [QWPath:QWPathTraceManager]) ->  (isDirty:Bool, description: String) {
    var desc: String = ""
    var isDirty = false

    if alwaysTrigger {
      return (isDirty:true, description: "AlwaysTrigger")
    }

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
    
    
    return (isDirty:false, description: "Not Dirty")
  }

  func triggerIfDirty(_ dataUsage: DataUsage?, dataDict: [QWPath:QWPathTraceManager])
  {
    // Let check this if target has been released since last removal.
    guard let _ = target else {
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
    if let _ = dataUsage {
      registrationUsage?.updateCollectorActionSet(collectorSet: self.registration.collectorPathSet)
      registrationUsage?.startCollecting()
      notificationClosure()
      registrationUsage?.stopCollecting()
    } else {
      // Call the registered selector on the target
      notificationClosure()
    }
  }

  func displayUsage() {
    let _ = self.registrationUsage?.displayUsage()
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
}
