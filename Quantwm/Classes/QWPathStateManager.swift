//
//  QWPathTraceReader.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 29/04/16.
//  Copyright © 2016 XL Software Solutions. => MIT License
//

import Foundation

class QWPathTraceReader
{
  let qwPath: QWPath
  private var nodeChain: QWPathTraceProtocol?
  private var updatedNodeChain: QWPathTraceProtocol?
  var updateCounter: Int = 0
  
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
  
  func readAndCompareTrace(rootNode: QWRootHandle)
  {
    guard let rootObject = rootNode.rootObject else {
        // No Root Node. Clear chain and return
        // If root node was previous present, then there is a change
        if let _ = self.nodeChain {
          self.nodeChain = nil
          self.updateCounter += 1
          print("QWPathTraceReader: \(keypath) dirty. Rootnode has changed to nil")
        } else {
          print("QWPathTraceReader: \(keypath) clean. No Rootnode")
        }
        return
    }
    
    // The root node is not nil.
    // Let's read  and compare the chains
    let updatedNodeChain: QWPathTraceProtocol = rootObject.generateQWPathTrace(qwPath: qwPath)

    // If self.updatedNodeChain is not nil, we are resuming from a suspendRefresh, and must check additional changes, else this is a start refresh
    let previousPathState = self.updatedNodeChain ?? self.nodeChain
    let comparison = updatedNodeChain.compareWithPreviousState(previousPathState)
    self.updatedNodeChain = updatedNodeChain
    if comparison.isDirty {
      self.updateCounter += (comparison.isDirty ? 1 : 0)
      print("QWPathTraceReader: \(keypath) : \(comparison.description) counter updated to \(updateCounter)")
    } else {
      print("QWPathTraceReader: \(keypath) : \(comparison.description)")
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
  
  var propertyDescriptionSet: Set<QWPropertyID> {
    var result = Set(arrayLiteral: qwPath.root.descriptor)
    result.formUnion(qwPath.chain.map({$0.descriptor}))
    return result
  }
  
  // This function is only providing correct result just after a readChain method
  func collectNodeSet() -> Set<RW_Action>
  {
    if let nodeSet = self.updatedNodeChain?.collectChainActionSet() {
      return nodeSet
    } else {
      return Set<RW_Action>()
    }
  }

}
