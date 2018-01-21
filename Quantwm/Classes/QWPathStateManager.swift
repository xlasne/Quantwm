//
//  QWPathTraceManager.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 29/04/16.
//  Copyright  MIT License
//

import Foundation

// QWPathTraceManager is in charge of a single QWPath
// and increment his updateCounter each time this path is modified
class QWPathTraceManager
{
  let qwPath: QWPath

  // At the end of RefreshUI(), on commitUpdate():
  // nodeChain is reset with updatedNodeChain
  // updatedNodeChain = nil

  // At each readAndCompareTrace:
  // updatedNodeChain is compared versus updatedNodeChain ?? nodeChain
  // updateCounter is incremented if different
  private var nodeChain: QWPathTraceSnapshot?
  private var updatedNodeChain: QWPathTraceSnapshot?
  private(set) var updateCounter: Int = 0
  
  var keypathBase: String {
    return qwPath.rootPath
  }
  var keypathExtension: String? {
    return qwPath.extensionPath
  }
    
  init(qwPath: QWPath)
  {
    self.qwPath = qwPath
  }

  // Increment updateCounter is the path is dirty versus nodeChain
  func clearTraceOnNilRootNode()
  {
    // No Root Node. Clear chain and return
    // If root node was previous present, then there is a change
    if let _ = self.nodeChain {
      self.nodeChain = nil
      self.updateCounter += 1
      Swift.print("QWPathTraceManager: \(keypath) dirty. Rootnode has changed to nil")
    } else {
      Swift.print("QWPathTraceManager: \(keypath) clean. No Rootnode")
    }
    return
  }

  func readAndCompareTrace(rootNode: QWRoot)
  {

    // The root node is not nil.
    // Let's read  and compare the chains
    let updatedNodeChain: QWPathTraceSnapshot = rootNode.generateQWPathTrace(qwPath: qwPath)

    // If self.updatedNodeChain is not nil, we are resuming from a suspendRefresh, and must check additional changes, else this is a start refresh
    let previousPathState = self.updatedNodeChain ?? self.nodeChain
    let comparison = updatedNodeChain.compareWithPreviousState(previousPathState)
    self.updatedNodeChain = updatedNodeChain
    if comparison.isDirty {
      self.updateCounter += (comparison.isDirty ? 1 : 0)
      Swift.print("QWPathTraceManager: \(keypath) : \(comparison.description) counter updated to \(updateCounter)")
    } else {
//      Swift.print("QWPathTraceManager: \(keypath) : \(comparison.description)")
    }
    
  }

  func commitUpdate() {
    self.nodeChain = self.updatedNodeChain
    self.updatedNodeChain = nil
  }

  var keypath: String {
    return qwPath.keypath
  }
  
  var composedKeypath: String {
    if let ext = keypathExtension {
      return "\(keypathBase):\(ext)"
    } else {
      return keypathBase
    }
  }
}
