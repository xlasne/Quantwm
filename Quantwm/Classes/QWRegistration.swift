//
//  QWRegistration.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 19/05/16.
//  Copyright © 2016 XL Software Solutions. => MIT License
//

import Foundation

enum QWRegistrationType {
  case AlwaysTrigger
  case Collector
  case HardScheduling
  case SmartScheduling
}

public final class QWRegistration: NSObject, Encodable
{

  enum CodingKeys: String, CodingKey {
    case readPathSet
    case name
    case writtenPathSet
    case schedulingPriority
  }

  let readPathSet: Set<QWPath>        // If empty, trigger on each refresh
  let name: String
  let writtenPathSet: Set<QWPath>
  let schedulingPriority: Int?
  let registrationType: QWRegistrationType
  var collectorPathSet: Set<QWPath> = []   // Contains collector values which can be read, but does not require registration to because their contract is managed via Collector.

  internal init(registrationType: QWRegistrationType,
       readMap: QWMap,
       name: String,
       writtenMap: QWMap = QWMap(pathArray : []),
       schedulingPriority: Int?)
  {
    self.registrationType = registrationType
    self.readPathSet = readMap.qwPathSet
    self.name = name
    self.writtenPathSet = writtenMap.qwPathSet
    self.schedulingPriority = schedulingPriority

    for path in readMap.qwPathSet {
      if path.access == .writePath {
        assert(false, "Error: Registration \(name) contains a write readPath : \(path)")
      }
    }

    for path in writtenMap.qwPathSet {
      if path.access == .readPath {
        assert(false, "Error: Registration \(name) contains a read in writePath : \(path)")
      }
    }

  }

  var writtenPropertySet: Set<QWProperty> {
    return Set(self.writtenPathSet.flatMap{ $0.chain.last })
  }

  var alwaysTriggers: Bool {
    return readPathSet.isEmpty
  }

  /*
   Collector Registration:
   - Collected Set
   - Collector Counter

   Rule:
   - If any property of the Collected set is modified, then Collector counter is incremented.
   - Collector Counter can be incremented without Collected set update (update of non monitored property).
   - Once a notification with Collector-Read has been sent, no change to the Collected set is allowed

   Subscription as Write:
   - Collected Set is included in the registration Read Set
   - Collector property is included in the WrittenSet

   Subscription as Read:
   - Collected Set is included as properties which can be read, but do not need to be registered.
   - Collector property is part of the read set

   ** Active Collector **
   - Any component updating a property of the read set shall increment the collector.

   Scheduling:
   - Hard scheduling:
   - No need to declare it in write
   - Smart Scheduling:
   - Registration can declare the collectorPath in write or read
   - The collector level is computed based on collectorPath level.


   ** Passive Collector **
   - Collector is scheduled as a normal Processing in Smart scheduling.
   with read and write set
   - On activation, the incrementClosure is performed.
   - This is a regular registration, with a closure instead of a selector
   -> Need to replace selector by closure

   Scheduling:

   Step 1:
   - Define a QWCollector object
   Step 2:
   - Register a QWCollector object

   */

  public convenience init(collectorWithReadMap collectedMap: QWMap,
              name: String,
              collectorMap: QWMap,
              schedulingPriority: Int? = nil) {

    for path in collectedMap.qwPathSet {
      if path.access == .writePath {
        assert(false, "Error: Registration \(name) contains a write path in collectedMap : \(path)")
      }
    }

    assert(!collectedMap.qwPathSet.isEmpty,"QWCollector \(name): readMap shall not be empty")
    assert(collectorMap.qwPathSet.count == 1,"QWCollector \(name): collectorMap shall only contains one property path")
    if let path = collectorMap.qwPathSet.first {
      assert(path.type == .property, "QWCollector \(name): collectorPath shall be a property path")
    }

    self.init(registrationType: QWRegistrationType.Collector,
               readMap: collectedMap,
               name: name,
               writtenMap: collectorMap,
               schedulingPriority: schedulingPriority)
  }

  public convenience init(smartWithReadMap readMap: QWMap,
              name: String,
              writtenMap: QWMap = QWMap(pathArray : [])) {

    for path in readMap.qwPathSet {
      if path.access == .writePath {
        assert(false, "Error: Registration \(name) contains a write readPath : \(path)")
      }
    }

    for path in writtenMap.qwPathSet {
      if path.access == .readPath {
        assert(false, "Error: Registration \(name) contains a read in writePath : \(path)")
      }
    }

    self.init(registrationType: QWRegistrationType.SmartScheduling,
               readMap: readMap,
               name: name,
               writtenMap: writtenMap,
               schedulingPriority: nil)
  }

  public convenience init(hardWithReadMap readMap: QWMap,
              name: String,
              schedulingPriority: Int) {

    for path in readMap.qwPathSet {
      if path.access == .writePath {
        assert(false, "Error: Registration \(name) contains a write readPath : \(path)")
      }
    }

    self.init(registrationType: QWRegistrationType.HardScheduling,
               readMap: readMap,
               name: name,
               writtenMap: QWMap(pathArray : []),
               schedulingPriority: schedulingPriority)
  }

  public convenience init(alwaysRefreshWithName name: String) {

    self.init(registrationType: QWRegistrationType.AlwaysTrigger,
              readMap: QWMap(pathArray : []),
              name: name,
              writtenMap: QWMap(pathArray : []),
              schedulingPriority: nil)
  }

  public func injectCollectors(_ collectorSet: Set<QWRegistration>) {
    self.collectorPathSet = []
    for reg in collectorSet {
      assert(reg.writtenPathSet.count == 1)
      assert(reg.registrationType == .Collector)
      if let collectorPath = reg.writtenPathSet.first {
        if self.readPathSet.contains(collectorPath) {
          self.collectorPathSet.formUnion(reg.readPathSet)
        }
      }
    }
  }

}


