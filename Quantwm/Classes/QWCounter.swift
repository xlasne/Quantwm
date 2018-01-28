//
//  QWCounter.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 15/04/16.
//  Copyright  MIT License
//

import Foundation

//MARK: - QWCounter
// Each monitored class or struct shall have a qwCounter property
// QWCounter increments the property counter each time the property is updated
// QWCounter checks that reads and writes are performed on Main Thread
// QWCounter also increments read or write dataUsage for debug monitoring

// Change watcher shall not be copied from an object to the other.
// If the object is copied, create a new qwCounter

typealias NodeId = Int32

//ReadOnly

//allowBackgroundRead

//allowBackgroundWrite

//not discardable or
//discardable: Discardable generates an Undo step marked as Discardable
//derived: Derived


public struct QWCounterAccessOption: OptionSet {
  public let rawValue: Int

  public init(rawValue: QWCounterAccessOption.RawValue) {
    self.rawValue = rawValue & 7
  }

  public static let none            = QWCounterAccessOption(rawValue: 0)
  public static let backgroundRead  = QWCounterAccessOption(rawValue: 1)  // versus read on main thread only
  public static let backgroundWrite = QWCounterAccessOption(rawValue: 2)  // versus write on main thread only
}

public enum QWCounterStorageOption {
  case stored
  case discardable
  case derived
}

public enum QWStorageDecision {
  case noChange
  case discardableChange
  case storedChange

  func reduce(_ decision: QWStorageDecision) -> QWStorageDecision {
    switch (self, decision) {
    case (.storedChange, _):
      return .storedChange
    case (_, .storedChange):
      return .storedChange
    case (.discardableChange, _):
      return .discardableChange
    case (_, .discardableChange):
      return .discardableChange
    case (.noChange, .noChange):
      return .noChange
    }
  }

  var isUpdated: Bool {
    switch self {
    case .noChange:
      return false
    case .discardableChange:
      return true
    case .storedChange:
      return true
    }
  }

  var isDiscardable: Bool {
    switch self {
    case .noChange:
      return false
    case .discardableChange:
      return true
    case .storedChange:
      return false
    }
  }
}




open class QWCounter: NSObject, Codable {

  enum QWCounterAccess: Int {
    case NoAccess         = 2
    case ReadAccess       = 1
    case ReadWriteAccess  = 0   // or no Tag
    case ReadOnlyAccess   = -1
  }

  static var ASSERT_ON_VIOLATION = true

  // Compliance to Codable is ... very partial
  // On restoration, only node name will be restored
  enum CodingKeys: String, CodingKey {
    case nodeName
  }

  //MARK: Properties

  private static var queue = DispatchQueue(label: "nodeIdGenerator.quantwm")
  private (set) static var nodeIdGenerator: NodeId = 0

  var activated: Bool = true

  // Unique NodeId Generator
  static func generateUniqueNodeId() -> NodeId {
    var nodeId: NodeId = -1
    queue.sync {
      QWCounter.nodeIdGenerator += 1
      nodeId = QWCounter.nodeIdGenerator
    }
    assert(nodeId >= 0,"Error in nodeIdGenerator.quantwm")
    return nodeId
  }

  public let nodeName: String

  public init(name: String) {
    self.nodeName = name
    super.init()
  }

  // NodeId uniquely identify this node. Used by DataUsage
  let nodeId: NodeId  = QWCounter.generateUniqueNodeId()
  
  // Maintain a change counter for each value or reference property of its parent object/struct
  // Counter is created at 0 when requested
  var changeCountDict: [AnyKeyPath:Int] = [:]

  // defaultAccess is for property which have not yet been accessed,
  // and are thus not yet in the dictionary
  var accessTag:String = ""  // To manage case of node which have been removed from the tree, then inserted during refresh phase, and whose access level are obsolete
  var defaultAccess:QWCounterAccess = .NoAccess
  var accessDict: [AnyKeyPath:QWCounterAccess] = [:]

  //MARK: - Read / Write monitoring

  public func read(_ property: QWProperty,
                   backgroundRead: Bool = false,
                   storageOptions: QWCounterStorageOption = .stored) {
    if !activated { return }

    if !backgroundRead {
      let childKey = property.propKey
      if !Thread.isMainThread {
        assert(false, "Monitored Node: Error: writing from \(childKey) from background thread is a severe error")
      }
    }

    if let dataUsage = DataUsage.currentInstance(),
      dataUsage.readMonitoringIsActive {
      dataUsage.addRead(self, property: property.descriptor)
      checkReadAccess(dataUsage: dataUsage, property: property)
    }

  }

  public func write(_ property: QWProperty,
                    backgroundWrite: Bool = false,
                    storageOptions: QWCounterStorageOption = .stored)
  {
    if !activated { return }

    if !backgroundWrite {
      let childKey = property.propKey
      if !Thread.isMainThread {
        assert(false, "Monitored Node: Error: writing from \(childKey) from background thread is a severe error")
      }
    }
    self.setDirty(property)

    stageChange(storageOptions: storageOptions)

    if let dataUsage = DataUsage.currentInstance() {
      dataUsage.addWrite(self, property: property.descriptor)
      checkWriteAccess(dataUsage: dataUsage, property: property)
    }
  }

  //MARK: - Access management
  func checkReadAccess(dataUsage: DataUsage, property: QWProperty) {
    if dataUsage.currentTag == accessTag,
        dataUsage.readMonitoringIsActive {
      // This counter is monitored .. Let's continue
      if let access = accessDict[property.propKey] {
        switch access {
        case .NoAccess:
          assert(false,"Error: Reading property \(property.propDescription) while this property is tagged NoAccess. This property needs to be added to current QWRegistration readSet")
        case .ReadAccess:
          break
        case .ReadWriteAccess:
          break
        case .ReadOnlyAccess:
          break
        }
      }
    }
  }

  func checkWriteAccess(dataUsage: DataUsage, property: QWProperty) {
    if dataUsage.currentTag == accessTag,
      dataUsage.writeMonitoringIsActive {
      // This counter is monitored .. Let's continue
      if let access = accessDict[property.propKey] {
        switch access {
        case .NoAccess:
          assert(false,"Error: Writing property \(property.propDescription) while this property is tagged NoAccess. This property needs to be added to current QWRegistration writeSet")
        case .ReadAccess:
          assert(false,"Error: Writing property \(property.propDescription) while this property is tagged ReadAccess. This property needs to be added to current QWRegistration writeSet")
        case .ReadWriteAccess:
          break
        case .ReadOnlyAccess:
          assert(false,"Error: Writing property \(property.propDescription) while this property is tagged ReadOnlyAccess. This property needs to be added to current QWRegistration writeSet")
        }
      }
    }
  }

  func applyNoAccess(tag: String) {
    defaultAccess = .NoAccess
    accessTag = tag
    for keypath in accessDict.keys {
      accessDict[keypath] = QWCounterAccess.NoAccess
    }
  }

  func applyReadAccess(keypath: AnyKeyPath, tag: String) {
    if tag != accessTag {
      // This is a node coming from out scope
      accessTag = tag
      for keypath in accessDict.keys {
        accessDict[keypath] = QWCounterAccess.ReadWriteAccess // Default for new nodes
      }
      return
    }
    if let accessVal = accessDict[keypath] {
      switch accessVal {
      case .NoAccess:
        accessDict[keypath] = QWCounterAccess.ReadAccess
      case .ReadAccess:
        break
      case .ReadWriteAccess:
        break
      case .ReadOnlyAccess:
        break
      }
    } else {
      // This is a new property
      accessDict[keypath] = QWCounterAccess.ReadAccess
    }
  }

  func applyWriteAccess(keypath: AnyKeyPath, tag: String) {
    if tag != accessTag {
      // This is a node coming from out scope
      accessTag = tag
      for keypath in accessDict.keys {
        accessDict[keypath] = QWCounterAccess.ReadWriteAccess // Default for new nodes
      }
      return
    }
    if let accessVal = accessDict[keypath] {
      switch accessVal {
      case .NoAccess:
        accessDict[keypath] = QWCounterAccess.ReadWriteAccess
      case .ReadAccess:
        accessDict[keypath] = QWCounterAccess.ReadWriteAccess
      case .ReadWriteAccess:
        break
      case .ReadOnlyAccess:
        break
      }
    } else {
      // This is a new property
      accessDict[keypath] = QWCounterAccess.ReadWriteAccess
    }
  }

  func applyReadOnlyAccess(keypath: AnyKeyPath, tag: String) {
    if tag != accessTag {
      // This is a node coming from out scope
      accessTag = tag
      for keypath in accessDict.keys {
        accessDict[keypath] = QWCounterAccess.ReadWriteAccess // Default for new nodes
      }
      // No return this time
    }
    accessDict[keypath] = QWCounterAccess.ReadOnlyAccess
  }

  //MARK: - Update Property Management
  
  // Increment changeCount for a property
  fileprivate func setDirty(_ property: QWProperty)
  {
//    Swift.print("Monitoring Node: Child \(property.propDescription) dirty")

    if let previousValue = self.changeCountDict[property.propKey] {
      self.changeCountDict[property.propKey] = previousValue + 1
    } else {
      self.changeCountDict[property.propKey] = 1
    }
  }
  
  // Get current changeCount for a property
  func changeCount(_ property: QWProperty) -> Int
  {
    if let changeCount = self.changeCountDict[property.propKey] {
      return changeCount
    } else {
      self.changeCountDict[property.propKey] = 0
      return 0
    }
  }

  //MARK: - Tree update detection for Undo
  //
  // A commit tag is set on each node of the tree at the end of the model update
  // The committer knows how to scan the tree, QWCounter only manage his local node.
  // The tag is set on the node, not on each properties.
  // On each *stored* (versus *discardable*) property change, the current tag is cleared
  // When the tag is set recursively, it also recursively collect the information if the previous
  // tag was cleared or not, indicating if the node (and thus the tree) has been updated.

  //      Created--->Written
  //         |         |
  //         v         |
  //  -->Committed()<--|
  //  |      |
  //  |      v
  //  |--UpdateAllowed()
  //  |      |
  //  |      v
  //  ----Written
  //

  enum UpdateState {
    case Created
    case Committed(String)
    case UpdateAllowed(String)
    case DiscardableWrite
    case Written
  }

  var state: UpdateState = .Created

  func commit(tag: String) {
    state = .Committed(tag)
  }

  func allowUpdate(tag: String) {
    if QWCounter.ASSERT_ON_VIOLATION {
      switch state {
      case .Created:
        // On the very first creation, tag = "" disable this check
        if tag.count > 0 {
          assert(false,"Creation shall occur during update phase")
        }
      case .Committed(let previousTag):
        assert(tag == previousTag,"commit tag shall match")
      case .Written, .DiscardableWrite:
        if tag.count > 0 {
          assert(false,"Node has been written out of update phase")
        }
      case .UpdateAllowed:
        Swift.print("Error: allowUpdate performed twice on the same node \(nodeName)")
//        assert(false,"allowUpdate performed twice on the same node")
      }
    }
    state = .UpdateAllowed(tag)
  }

  func stageChange(storageOptions: QWCounterStorageOption) {
    if QWCounter.ASSERT_ON_VIOLATION {
      switch state {
      case .Committed:
        assert(false,"Node write out of update phase")
      default:
        break
      }
    }

    switch storageOptions {
    case .stored:
      state = .Written
      break
    case .discardable:
      if case .Written = state   {
        break
      } else{
        state = .DiscardableWrite
      }
    case .derived:
      return   // Derived: Does not clear of the commit tag / stageChange
               // -> does not trigger a save
    }
  }

  func isUpdated(tag: String) -> QWStorageDecision {
    switch state {
    case .Created:
      return QWStorageDecision.storedChange
    case .Committed(let previousTag):
      if QWCounter.ASSERT_ON_VIOLATION {
        assert(tag == previousTag,"commit tag shall match")
      }
      return QWStorageDecision.noChange
    case .Written:
      return QWStorageDecision.storedChange
    case .DiscardableWrite:
      return QWStorageDecision.discardableChange
    case .UpdateAllowed(let previousTag):
      if QWCounter.ASSERT_ON_VIOLATION {
        assert(tag == previousTag,"commit tag shall match")
      }
      return QWStorageDecision.noChange
    }
  }

}

