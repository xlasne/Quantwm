//
//  QWDependencyMgr.swift
//  Spiky
//
//  Created by Xavier on 01/12/2017.
//  Copyright © 2017 XL Software Solutions. => MIT License
//

import Foundation

// The goal of this class is to compute the dependency level of each property.
// Each time a new QWRegistration is added or removed to a given QWRoot:
// - For each written property, add them in the dependency set of the corresponding reading properties.
// - Then compute the level of each registered QWProperty
// - Then compute the level of each registered QWPath
// - Then compute the level of each registered QWRegistration

public class QWDependencyMgr: Encodable {

  // Codable for logging purpose only
  enum CodingKeys: String, CodingKey {
    case propertySet
    case dependsFromPropertySet
    case propertyLevel
    case registrationLevel
  }

  var propertySet:Set<QWProperty>
  var dependsFromPropertySet: [QWProperty:Set<QWProperty>]
  var propertyLevel: [QWProperty:Int]
  var registrationLevel: [QWRegistration:Int]
  var writtenPropertySet:Set<QWProperty>
  var registrationSet: Set<QWRegistration>

  static func isDependencyRequired(observerSet: Set<QWObserver>) -> Bool {
    let observedSetCount = observerSet
      .filter() {$0.hasBeenDependencyOrdered == false}
      .count
    return observedSetCount > 0
  }

  init(observerSet: Set<QWObserver>) {
    observerSet.forEach({$0.hasBeenDependencyOrdered = true})
    
    self.registrationSet = Set(observerSet.map({$0.registration}))
    self.registrationSet = registrationSet
      .filter() {$0.schedulingPriority == nil}
      .filter() {!($0.readPathSet.isEmpty)}
    self.propertySet = []
    self.dependsFromPropertySet = [:]
    self.propertyLevel = [:]
    self.registrationLevel = [:]
    self.writtenPropertySet = []

    // Inject Collectors
    // A registration of type Collector shall obey the rule that
    // if a property of the collector read set has been updated,
    // then the collectorMap is updated.
    // Thus, registering to the collectorMap entitle to read the properties in collector read set
    // without registering to them in the read set.
    func findCollectors(reg: QWRegistration) -> QWObserver? {
      let filteredObserver = observerSet
        .filter({$0.registration.name == reg.name})
      assert(filteredObserver.count == 1 ,"Collector \(reg.name) is declared as collector and is registered \(filteredObserver.count) times")
      return filteredObserver.first
    }

    for observer in observerSet {
      if observer.registration.collectors.count > 0 {
        observer.collectorObserver = []
        for collectorReg in observer.registration.collectors {
          if let collectorObs = findCollectors(reg: collectorReg) {
            observer.collectorObserver.append(collectorObs)
          } else {
            assert(false,"Collector \(collectorReg.name) is declared as collector by \(observer.registration.name), but not active")
          }
        }
      } else {
        observer.collectorObserver = []
      }
    }

    // Start computation
    computeDependsFromPropertySet()
    computeAllPropertiesLevel()
    let maxLevel = computeRegistrationLevel()

    // Consistency Check
    // Written Properties can only belong to one QWRegistration
    // Written Properties shall have greater level than read properties
    checkWrittenProperties()

    let alwaysTriggerArray = observerSet
      .map({$0.registration})
      .filter() {$0.schedulingPriority == nil}
      .filter() {$0.readPathSet.isEmpty}

    for reg in alwaysTriggerArray {
      registrationLevel[reg] = maxLevel + 1
    }
    self.registrationSet.formUnion(alwaysTriggerArray)

  }

  func level(reg: QWRegistration) -> Int? {
    return registrationLevel[reg]
  }


  // - For each written property, add them in the dependency set of the corresponding reading properties.
  func computeDependsFromPropertySet() {
    for reg in registrationSet {
      for qwPath in reg.readPathSet {
        for readProperty in qwPath.chain { // QWRoot is not monitored
          propertySet.insert(readProperty)
          for writtenProperty in reg.writtenPropertySet {
            propertySet.insert(writtenProperty)
            if var propSet = dependsFromPropertySet[writtenProperty] {
              propSet.insert(readProperty)
              dependsFromPropertySet[writtenProperty] = propSet
            } else {
              dependsFromPropertySet[writtenProperty] = [readProperty]
            }
          }
        }
      }
    }
  }

  // - Then compute the level of each registered QWProperty
  func computeAllPropertiesLevel() {
    for property in propertySet {
      propertyLevel[property] = self.computePropertyLevel(property: property, propertyArray: [])
    }
  }

  func computePropertyLevel(property: QWProperty, propertyArray: [QWPropertyID]) -> Int {
    let dependArray = self.dependsFromPropertySet[property] ?? []
    if propertyArray.contains(property.descriptor) {
      assert(false,"Property write depedency cycle: adding \(property.descriptor) to \(propertyArray))")
      return 1
    }

    if dependArray.isEmpty {
      return 1
    }

    let propertyArrayExtended = [property.descriptor] + propertyArray

    var maxChildLevel = 0
    for prop in dependArray {
      let childLevel = computePropertyLevel(property: prop, propertyArray: propertyArrayExtended)
      maxChildLevel = max(maxChildLevel, childLevel)
    }
    return maxChildLevel + 1
  }

  // - Then compute the level of each QWRegistration
  func computeRegistrationLevel() -> Int {
    var maxLevel = 0
    for reg in registrationSet {
      var level = 0
      for qwPath in reg.readPathSet {
        for readProperty in qwPath.chain { // QWRoot is not monitored
          guard let propLevel = propertyLevel[readProperty] else {
            assert(false,"Missing propertyLevel: should have been computed before")
            continue
          }
          if propLevel > level {
            level = propLevel
          }
        }
      }
      registrationLevel[reg] = level
      if level > maxLevel {
        maxLevel = level
      }
    }
    return maxLevel
  }

  func checkWrittenProperties() {
    for reg in registrationSet {
      guard let regLevel = registrationLevel[reg] else { continue }
      for writtenProperty in reg.writtenPropertySet {
        if writtenPropertySet.contains(writtenProperty) {
          assert(false,"Property \(writtenProperty.propDescription) belong to 2 writtenPropertySet")
        }
        writtenPropertySet.insert(writtenProperty)

        guard let writtenPropLevel = propertyLevel[writtenProperty] else {
          assert(false,"Missing propertyLevel: should have been computed before")
          continue
        }
        if writtenPropLevel <= regLevel {
          assert(false,"Property Cycle")
        }
      }
    }
  }

  func debugDescription() {
    let jsonEncoder = JSONEncoder()
    jsonEncoder.outputFormatting = .prettyPrinted
    do {
      let jsonData = try jsonEncoder.encode(self)
      let jsonString = String(data: jsonData, encoding: .utf8)
      Swift.print("JSON String : " + jsonString!)
    }
    catch {}
  }
}



