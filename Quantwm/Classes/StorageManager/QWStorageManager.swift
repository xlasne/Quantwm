//
//  QWStorageManager.swift
//  Spiky
//
//  Created by Xavier on 28/01/2018.
//  Copyright © 2018 XL Software Solutions. All rights reserved.
//

import Foundation

protocol QWStorageManagerProtocol: class {
  func registerModel(modelRootNode: QWRoot, modelUpdatedClosure: @escaping ()->())
  func unregisterModel()
  func beforeUpdateHandler()
  func endOfRefreshHandler()
}

class QWStorageManager: QWStorageManagerProtocol {

  // Undo Managment
  // Root Node of the Model to be archived
  weak var modelRootNode: QWRoot?

  // Indicates that model shall be saved
  var modelUpdatedClosure: (()->())?

  init() {
    self.modelRootNode = nil
    self.modelUpdatedClosure = nil
  }

  // Model shall be created under updateAndRefresh
  func registerModel(modelRootNode: QWRoot, modelUpdatedClosure: @escaping ()->()) {
    self.modelRootNode = modelRootNode
    self.modelUpdatedClosure = modelUpdatedClosure
    QWTreeWalker.scanNodeTreeMap(fromParent: modelRootNode, closure: { (node: QWNode) in
      node.getQWCounter().storageState.commit()
    })
  }

  func unregisterModel() {
    self.modelUpdatedClosure = nil
  }

  func beforeUpdateHandler() {
    if QWConfiguration.QUANTWM_DEBUG {
      if let root = modelRootNode {
        QWTreeWalker.scanNodeTreeMap(fromParent: root, closure: { (node: QWNode) in
          node.getQWCounter().storageState.allowUpdate()
        })
      }
    }
  }

  func endOfRefreshHandler() {
    modelUpdatedClosure?()
//    if QWConfiguration.QUANTWM_DEBUG {
//      // Commit the changes
//      if let root = modelRootNode {
//        QWTreeWalker.scanNodeTreeMap(fromParent: root, closure: { (node: QWNode) in
//          node.getQWCounter().storageState.commit()
//        })
//      }
//    }
  }

  // Used by Undo Management
  public func isUpdated(parent: QWNode) -> QWStorageDecision {
    let isUpdated = QWTreeWalker.scanNodeTreeReduce(
      fromParent: parent,
      initialResult: QWStorageDecision.noChange,
      { (storageDecision, node) -> QWStorageDecision in
        let nodeIsUpdated = node.getQWCounter().storageState.isUpdated()
        node.getQWCounter().storageState.commit()
        switch nodeIsUpdated {
        case .noChange:
          break
        case .discardableChange:
          Swift.print("IsDiscardableUpdated: \(node.getQWCounter().nodeName): \(node.getQWCounter().storageState.state)")
        case .storedChange:
          Swift.print("IsStorageUpdated: \(node.getQWCounter().nodeName): \(node.getQWCounter().storageState.state)")
        }
        return storageDecision.reduce(nodeIsUpdated)
    })
    return isUpdated
  }

}
