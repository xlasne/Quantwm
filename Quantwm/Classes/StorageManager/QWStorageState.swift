//
//  QWStorageState.swift
//  Spiky
//
//  Created by Xavier on 28/01/2018.
//  Copyright © 2018 XL Software Solutions. All rights reserved.
//

import Foundation

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


class QWStorageState {

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
    case Committed
    case UpdateAllowed
    case DiscardableWrite
    case Written
  }

  var state: UpdateState = .Created

  func allowUpdate() {
    state = .UpdateAllowed
  }

  func commit() {
    state = .Committed
  }

  func stageChange(storageOptions: QWCounterStorageOption) {
    if QWConfiguration.QUANTWM_DEBUG {
      switch state {
      case .Committed:
        QWConfiguration.StorageConsistency.process(errorStr: "Node write out of update phase")
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

  func isUpdated() -> QWStorageDecision {
    switch state {
    case .Created:
      return QWStorageDecision.storedChange
    case .Committed:
      return QWStorageDecision.noChange
    case .Written:
      return QWStorageDecision.storedChange
    case .DiscardableWrite:
      return QWStorageDecision.discardableChange
    case .UpdateAllowed:
      return QWStorageDecision.noChange
    }
  }

}
