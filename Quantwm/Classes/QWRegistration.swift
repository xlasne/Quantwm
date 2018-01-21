//
//  QWRegistration.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 19/05/16.
//  Copyright  MIT License
//

import Foundation

enum QWRegistrationType {
  case AlwaysTrigger
  case Collector
  case HardScheduling
  case SmartScheduling
}


public class QWCollector: QWRegistration
{

  /// Initialization of a QWCollector, a specialized QWRegistration
  /// similar to a Smart Registration or Hard Registration depending on schedulingPriority,
  /// which can be monitored like a property via the collectors parameters.
  /// If Client A includes the QWCollector B in its registration, then A will be notified
  /// each time B is activated.
  /// Using collector is useful for performance when registering to a large collection of items
  /// via a sub-tree path: The collector monitor this collection,
  /// and factorize this read access for other registrations.
  ///
  /// If scheduling priority is defined: Hard Registration
  /// Read Access: Any property
  /// Write Access: Any property
  ///
  /// If scheduling priority is nil: Smart Registration
  /// Read Access: includes the collectedMap, the writtenMap,
  /// and recursive access to the collectors collectedMap and writtenMap.
  /// Write Access: writtenMap
  ///
  /// - Parameters:
  ///   - collectedMap: QWMap of the read paths triggering the notification.
  ///   - name: String identifying this registration.
  ///   - writtenMap: QWMap of the write paths. The written property is the last property of each write path.
  ///   - collectors: Optional array of QWCollectors.
  ///   - schedulingPriority: Optional Priority.
  public init(collectorWithReadMap collectedMap: QWMap,
                          name: String,
                          writtenMap: QWMap?,
                          collectors: [QWCollector] = [],
                          schedulingPriority: Int? = nil) {

    let writeMap = writtenMap ?? QWMap(pathArray:[])

    assert(!collectedMap.qwPathSet.isEmpty,"QWCollector \(name): readMap shall not be empty")

    super.init(registrationType: QWRegistrationType.Collector,
              readMap: collectedMap,
              name: name,
              writtenMap: writeMap,
              collectors: collectors,
              schedulingPriority: schedulingPriority)
  }
}

/// QWRegistration: 
public class QWRegistration: NSObject, Encodable
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
  var collectors:[QWCollector]
  var collectorPathSet: Set<QWPath> = []   // Contains collector values which can be read, but does not require registration to because their contract is managed via Collector.


  internal init(registrationType: QWRegistrationType,
       readMap: QWMap,
       name: String,
       writtenMap: QWMap = QWMap(pathArray : []),
       collectors: [QWCollector] = [],
       schedulingPriority: Int?)
  {
    self.registrationType = registrationType
    self.readPathSet = readMap.qwPathSet
    self.name = name
    self.writtenPathSet = writtenMap.qwPathSet
    self.schedulingPriority = schedulingPriority
    self.collectors = collectors
    self.collectorPathSet = QWRegistration.getCollectorPath(collectors: collectors)

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

  /// Smart Registration
  /// Scheduling: After Hard Registration, and before Recurring Registration
  /// Notification is triggered if any readMap property has changed since the last notification, or if readMap is empty.
  /// The scheduling order is computed based on the dependency level,
  /// which guaranty that readMap input property will not change until the end of the event loop.
  /// Read Access: readMap + recursive access to the collectors collectedMap and writtenMap.
  /// Write Access: limited to writtenMap
  ///
  /// - Parameters:
  ///   - readMap: QWMap of Read Path
  ///   - name: String identifying this registration.
  ///   - writtenMap: QWMap of the write paths. The written property is the last property of each write path.
  ///   - collectors: Array of QWCollectors, may be empty.
  public convenience init(smartWithReadMap readMap: QWMap,
              name: String,
              writtenMap: QWMap? = nil,
              collectors: [QWCollector] = []) {

    let writeMap = writtenMap ?? QWMap(pathArray:[])

    for path in readMap.qwPathSet {
      if path.access == .writePath {
        assert(false, "Error: Registration \(name) contains a write readPath : \(path)")
      }
    }

    for path in writeMap.qwPathSet {
      if path.access == .readPath {
        assert(false, "Error: Registration \(name) contains a read in writePath : \(path)")
      }
    }

    self.init(registrationType: QWRegistrationType.SmartScheduling,
               readMap: readMap,
               name: name,
               writtenMap: writeMap,
               collectors: collectors,
               schedulingPriority: nil)
  }

  /// Hard Registration
  /// Scheduling: Before Smart and Recurring Registration
  /// The scheduling order is computed based on the increasing schedulingPriority
  /// Notification is triggered if any readMap property has changed since the last notification
  /// Read Access: Any property
  /// Write Access: Any property
  ///
  /// - Parameters:
  ///   - readMap: QWMap of Read Path
  ///   - name: String identifying this registration.
  ///   - writtenMap: QWMap of the write paths. The written property is the last property of each write path.
  ///   - collectors: Array of QWCollectors, may be empty.
  public convenience init(hardWithReadMap readMap: QWMap,
              name: String,
              schedulingPriority: Int,
              collectors: [QWCollector] = []) {

    for path in readMap.qwPathSet {
      if path.access == .writePath {
        assert(false, "Error: Registration \(name) contains a write readPath : \(path)")
      }
    }

    self.init(registrationType: QWRegistrationType.HardScheduling,
               readMap: readMap,
               name: name,
               writtenMap: QWMap(pathArray : []),
               collectors: collectors,
               schedulingPriority: schedulingPriority)
  }

  /// Recurring Registration
  /// Scheduling: After Hard and Smart Registration
  /// Notification is triggered at each updateAndRefresh() call
  /// Read Access: Any property
  /// Write Access: No write allowed
  ///
  /// - Parameters:
  ///   - recurringWithName: String identifying this registration.
  public convenience init(recurringWithName name: String) {

    self.init(registrationType: QWRegistrationType.AlwaysTrigger,
              readMap: QWMap(pathArray : []),
              name: name,
              writtenMap: QWMap(pathArray : []),
              schedulingPriority: nil)
  }

  public static func getCollectorPath(collectors: [QWRegistration]) -> Set<QWPath> {
    var collectorPaths: Set<QWPath> = []
    for reg in collectors {
      collectorPaths.formUnion(reg.readPathSet)
      collectorPaths.formUnion(reg.writtenPathSet)
      collectorPaths.formUnion(reg.collectorPathSet)
    }
    return collectorPaths
  }
}


