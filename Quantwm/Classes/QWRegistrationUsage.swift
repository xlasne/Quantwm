//
//  QWRegistrationUsage.swift
//  Quantwm
//
//  Created by Xavier on 17/12/2017.
//

import Foundation

enum DataSetComparisonResult<T: Hashable>
{
  case error_WriteDataSetNotEmpty(Set<T>)
  case warning_ReadDataSetContainsMoreDataThanQWObserver(Set<T>)
  case info_ReadDataSetIsContainedIntoQWObserver(Set<T>)
  case identical
}


class QWRegistrationUsage {

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
  fileprivate var actionSelector: Selector { return registration.selector }
  var observedPathSet: Set<QWPath> { return registration.readPathSet }
  var writtenPathSet: Set<QWPath> { return registration.writtenPathSet }
  var name: String { return registration.name }

  init(registration: QWRegistration) {
    self.registration = registration
    self.unionReadDescription = []
  }

  deinit {
    let _ = displayUsage()
  }


  // Collect Actions during monitoring
  var writeActionSet: Set<RW_Action> = Set()
  var  readActionSet: Set<RW_Action> = Set()

  // Maintain the union of all the RW_Action which are actually read
  // in order to detect registration to unused actions
  // unionReadDescription is composed only of PropertyDescription which are the result of the comparison between
  // configured and actual RW_Action, based on their common node.
  fileprivate var unionReadDescription: Set<QWPropertyID>

  func callPerformSelectorWith(target: NSObject,
                               dataUsage: DataUsage,
                               dataDict: [QWPath:QWPathTraceManager])
  {
    // clearContext() clears the read and write actions, not the dirty flag
    // which is needed by other keySetObservers
    writeActionSet = []
    readActionSet = []

    // Read the reference set of actions associated to the pathStateManagers
    let configuredReadSet = self.readActionSet(dataDict)

    // Call the registered selector on the target
    target.perform(registration.selector)

    // Check consistency

    let commonPropertySet = commonProperties(actionSet1: readActionSet, actionSet2: configuredReadSet)
    unionReadDescription.formUnion(commonPropertySet)

    let result = QWRegistrationUsage.compareArrays(
      readAction: readActionSet, configuredReadAction: configuredReadSet,
      writeAction: writeActionSet, configuredWriteProperties: registration.writtenPropertySet,
      name: name)
    switch result {
    case .error_WriteDataSetNotEmpty(let delta):
      print("Error: QWRegistrationUsage \(name) performs a write of \(delta.map({$0.propDescription})) which is not part of the registered writtenProperty QWObserver. Consider manually adding these writtenProperty to the registered \(name) QWObserver")
      assert(false, "Error: QWRegistrationUsage \(name) performs a write of \(delta.map({$0.propDescription})) which is not part of the registered writtenProperty QWObserver. Consider manually adding these writtenProperty to the registered \(name) QWObserver")
    case .warning_ReadDataSetContainsMoreDataThanQWObserver(let delta):
      print("Warning: QWRegistrationUsage \(name) performs a read of \(delta.map({$0.propDescription})) which is not part of the registered QWObserver. Consider manually adding this keypath to the registered \(name) QWObserver")
      assert(false, "Warning: QWRegistrationUsage \(name) performs a read of \(delta.map({$0.propDescription})) which is not part of the registered QWObserver. Consider manually adding this keypath to the registered \(name) QWObserver")
    case .identical:
      print("QWRegistrationUsage: \(name) Identical")
    case .info_ReadDataSetIsContainedIntoQWObserver(_):
      print("QWRegistrationUsage: \(name) info_ReadDataSetIsContainedIntoQWObserver")
    }
  }

  func displayUsage() -> DataSetComparisonResult<QWPropertyID>
  {
    var configuredProperties: Set<QWPropertyID> = []
    for readPath in observedPathSet
    {
      let dataDesc:Set<QWPropertyID> = readPath.propertyDescriptionSet
      configuredProperties.formUnion(dataDesc)
    }

    if unionReadDescription == configuredProperties {
      print("QWRegistrationUsage cumulated: Info: \(name) matches exactly its QWObserver")
      return DataSetComparisonResult.identical
    }

    if unionReadDescription.isSubset(of: configuredProperties) {
      let delta = configuredProperties.subtracting(unionReadDescription)
      print("QWRegistrationUsage cumulated: Info: Read of \(name) does not perform read of \(delta.map({$0.propDescription})) which is part of the registered QWObserver. This is normal if these values are not read at each refresh cycle")
      return DataSetComparisonResult.info_ReadDataSetIsContainedIntoQWObserver(delta)
    }

    let delta = unionReadDescription.subtracting(configuredProperties)
    print("QWRegistrationUsage cumulated: Warning: Read of \(name) performs a read of \(delta.map({$0.propDescription})) which is not part of the registered QWObserver. Consider manually adding this keypath to the registered \(name) QWObserver")
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


  static func compareArrays(readAction:Set<RW_Action>, configuredReadAction:Set<RW_Action>,
                            writeAction:Set<RW_Action>, configuredWriteProperties:Set<QWProperty>,
                            name: String) -> DataSetComparisonResult<QWPropertyID>
  {
    // Only compare porperty desc
    let readActionSet = Set(readAction.map({$0.propertyDesc}))
    let configuredReadActionSet = Set(configuredReadAction.map({$0.propertyDesc}))
    let writeActionSet = Set(writeAction.map({$0.propertyDesc}))

    let configuredWritePropID = configuredWriteProperties.map { $0.descriptor }
    let writeDelta = writeActionSet.filter { (action:QWPropertyID) -> Bool in
      return !configuredWritePropID.contains(action)
    }
    if !writeDelta.isEmpty {
      return DataSetComparisonResult.error_WriteDataSetNotEmpty(Set(writeDelta))
    }
    if readActionSet == configuredReadActionSet {
      return DataSetComparisonResult.identical
    }

    if readActionSet.isSubset(of: configuredReadActionSet) {
      let delta = configuredReadActionSet.subtracting(readActionSet)
      return DataSetComparisonResult.info_ReadDataSetIsContainedIntoQWObserver(delta)
    }
    let delta = readActionSet.subtracting(configuredReadActionSet)
    return DataSetComparisonResult.warning_ReadDataSetContainsMoreDataThanQWObserver(delta)
  }
}

//MARK: - QWRegistrationUsageProtocol

protocol QWRegistrationUsageProtocol {
  func addReadAction(readAction: RW_Action)
  func addWriteAction(writeAction: RW_Action)
}

extension QWRegistrationUsage: QWRegistrationUsageProtocol {

func addReadAction(readAction: RW_Action) {
  readActionSet.insert(readAction)
}

func addWriteAction(writeAction: RW_Action) {
  writeActionSet.insert(writeAction)
}
}

