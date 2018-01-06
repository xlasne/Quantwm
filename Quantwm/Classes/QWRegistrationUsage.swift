//
//  QWRegistrationUsage.swift
//  Quantwm
//
//  Created by Xavier Lasne on 17/12/2017.
//

import Foundation

public class QWRegistrationUsage {

  /*
   The goal of this class is to collect the usage of the properties during the notification processing, and to compare them to the registration set.
   QWRegistrationUsage usage belong to QWObserver, if this observer is created with registrationUsageMonitoring = true.
   On perform notification, QWRegistrationUsage is added as parameter to the QWContextStack, and records via DataUsage
   the set of ReadAction and WriteAction performed.

   There is 2 kind of collection:
   - The collection of Read and Write during the perform notification, to check that each R/W action belong to the registration set.
   - The cumulated collection of Read action over multiple perform notification, to check the coverage of these cumulated read actions with the configured QWRegistration - over-registration detection.
   */
  
  let registration: QWRegistration
  var observedPathSet: Set<QWPath> { return registration.readPathSet }
  var writtenPathSet: Set<QWPath> { return registration.writtenPathSet }
  var name: String { return registration.name }
  var configuredCollectorPropertySet:Set<QWPropertyID>
  var configuredReadPropertySet:Set<QWPropertyID>
  var configuredWritePropertySet:Set<QWPropertyID>

  static func convertToProperty(paths:Set<QWPath>) -> Set<QWPropertyID> {
    var result = Set<QWPropertyID>()
    for path in paths {
      let properties = path.propertyDescriptionSet
      result.formUnion(properties)
    }
    return result
  }

  init(registration: QWRegistration) {
    self.registration = registration
    self.unionReadDescription = []
    self.unionWriteDescription = []
    let collectorProperties = QWRegistrationUsage.convertToProperty(paths: registration.collectorPathSet)
    self.configuredCollectorPropertySet = collectorProperties
    let readProperties = QWRegistrationUsage.convertToProperty(paths: registration.readPathSet)
    self.configuredReadPropertySet = readProperties
    let writtenProperties = Set(registration.writtenPropertySet.map({$0.descriptor}))
    self.configuredWritePropertySet = writtenProperties
  }

  deinit {
    let _ = displayUsage()
  }

  // Collect Actions during monitoring
  var writeActionSet: Set<RW_Action> = Set()
  var  readActionSet: Set<RW_Action> = Set()
  var collectorActionSet: Set<RW_Action> = Set()

  // Maintain the union of all the RW_Action which are actually read
  // in order to detect registration to unused actions
  // unionReadDescription is composed only of PropertyDescription which are the result of the comparison between
  // configured and actual RW_Action, based on their common node.
  fileprivate var unionReadDescription: Set<QWPropertyID>
  fileprivate var unionWriteDescription: Set<QWPropertyID>

  func startCollecting() {
    // startCollecting() clears the read and write actions, not the dirty flag
    // which is needed by other keySetObservers
    writeActionSet = []
    readActionSet = []
    collectorActionSet = []
  }

  func stopCollecting() {
    
    let commonReadPropertySet = commonProperties(actionSet: readActionSet, propertySet: configuredReadPropertySet)
    unionReadDescription.formUnion(commonReadPropertySet)
    
    let commonWritePropertySet = commonProperties(actionSet: writeActionSet, propertySet: configuredWritePropertySet)
    unionWriteDescription.formUnion(commonWritePropertySet)
    
    writeActionSet = []
    readActionSet = []
  }

  // Display the difference between the registered scope and the cumulated read/write actions
  // on the lifetime of an QWObserver.
  func displayUsage()
  {

    if (unionReadDescription == configuredReadPropertySet) &&
      (unionWriteDescription == configuredWritePropertySet)
    {
      Swift.print("QWRegistrationUsage cumulated: Info: \(name) matches exactly its QWRegistration")
    }

    let deltaRead = configuredReadPropertySet.subtracting(unionReadDescription)
    if !deltaRead.isEmpty {
      Swift.print("QWRegistrationUsage cumulated: Info: Read of \(name) does not perform read of \(deltaRead.map({$0.propDescription})) which is part of the QWRegistration.")
    }

    let deltaWrite = configuredWritePropertySet.subtracting(unionWriteDescription)
    if !deltaWrite.isEmpty {
      Swift.print("QWRegistrationUsage cumulated: Info: Write of \(name) does not perform write of \(deltaWrite.map({$0.propDescription})) which is part of the QWRegistration.")
    }
  }


  func commonProperties(actionSet:Set<RW_Action>, propertySet:Set<QWPropertyID>) -> Set<QWPropertyID>
  {
    return toPropertyId(actionSet: actionSet).intersection(propertySet)
  }

  func toPropertyId(actionSet:Set<RW_Action>) -> Set<QWPropertyID> {
    return  Set(actionSet.map{$0.propertyDesc})
  }

}

//MARK: - QWRegistrationUsageProtocol
// Monitor when a notification read or write outside of its defined scope

protocol QWRegistrationUsageProtocol {
  func addReadAction(readAction: RW_Action)
  func addWriteAction(writeAction: RW_Action)
}

extension QWRegistrationUsage: QWRegistrationUsageProtocol {

  func addReadAction(readAction: RW_Action) {
    if configuredReadPropertySet.isEmpty {
      return // No read monitoring on AlwaysTrigger
    }
    if QWConfiguration.ReadNonRegisteredProperty.notIgnore {
      if !configuredReadPropertySet.contains(readAction.propertyDesc) &&
        !configuredWritePropertySet.contains(readAction.propertyDesc) &&
        !configuredCollectorPropertySet.contains(readAction.propertyDesc){
        let errorStr = "QWRegistrationUsage: Warning: Read of \(name) performs a read of \(readAction.propertyDesc.propDescription) which is not part of the registered QWObserver. Consider manually adding this keypath to the registered \(name) QWObserver"
        QWConfiguration.ReadNonRegisteredProperty.process(errorStr: errorStr)
      }
    }
    if QWConfiguration.CollectPropertyUsage.notIgnore {
      if configuredCollectorPropertySet.contains(readAction.propertyDesc) {
        collectorActionSet.insert(readAction)
      } else {
        readActionSet.insert(readAction)
      }
    }
  }

  func addWriteAction(writeAction: RW_Action) {
    if QWConfiguration.WriteNonRegisteredProperty.notIgnore {
      if !configuredWritePropertySet.contains(writeAction.propertyDesc) {
        let errorStr = "QWRegistrationUsage: Warning: Write of \(name) performs a write of \(writeAction.propertyDesc.propDescription) which is not part of the registered QWObserver. Consider manually adding this keypath to the registered \(name) QWObserver"
        QWConfiguration.WriteNonRegisteredProperty.process(errorStr: errorStr)
      }
    }
    if QWConfiguration.CollectPropertyUsage.notIgnore {
      writeActionSet.insert(writeAction)
    }
  }
}

