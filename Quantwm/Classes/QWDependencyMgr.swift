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

  init(registrationSet: Set<QWRegistration>) {
    self.registrationSet = registrationSet.filter() {$0.configurationPriority == nil}
    self.propertySet = []
    self.dependsFromPropertySet = [:]
    self.propertyLevel = [:]
    self.registrationLevel = [:]
    self.writtenPropertySet = []

    // Start computation
    computeDependsFromPropertySet()
    computeAllPropertiesLevel()
    computeRegistrationLevel()

    // Consistency Check
    // Written Properties can only belong to one QWRegistration
    // Written Properties shall have greater level than read properties
    checkWrittenProperties()
  }

  func level(reg: QWRegistration) -> Int {
    return registrationLevel[reg]!
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
  func computeRegistrationLevel() {
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
    }
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
      print("JSON String : " + jsonString!)
    }
    catch {}
  }
}



