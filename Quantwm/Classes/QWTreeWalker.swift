//
//  QWTreeWalker.swift
//  Spiky
//
//  Created by Xavier Lasne on 19/11/2017.
//  Copyright  MIT License
//

import Foundation


public class QWTreeWalker {

  public static func scanNodeTreeMap(fromParent parent: QWNode, closure:(QWNode)->(), level: Int = 0) {
    if level > 100 {
      // TODO: Detect this failure by setting a node level, assuming the same node can not have 2 parent
      // maybe ... this should be usefull only for DEBUG.
      // or checking node history. Consumming useless CPU on release code ...
      assert(false,"Error scanNodeTreeMap: Probable Recursive failure. Reached limit of 100 levels")
    }
    closure(parent)
    let propArray = parent.getPropertyArray()
    for property in propArray {
      let foundNodes: [QWNode] = property.getChildArray(node: parent)
      for node in foundNodes {
        scanNodeTreeMap(fromParent: node, closure: closure, level: level + 1)
      }
    }
  }

  public static func scanNodeTreeReduce<Result>(fromParent parent: QWNode, initialResult: Result, _ nextPartialResult: (Result, QWNode) -> Result, level: Int = 0) -> Result {
    if level > 100 {
      assert(false,"Error scanNodeTreeReduce: Probable Recursive failure. Reached limit of 100 levels")
    }
    var finalResult: Result = nextPartialResult(initialResult,parent)
    let propArray = parent.getPropertyArray()
    for property in propArray {
      let foundNodes: [QWNode] = property.getChildArray(node: parent)
      for node in foundNodes {
        finalResult = scanNodeTreeReduce(fromParent: node, initialResult: finalResult, nextPartialResult, level: level + 1)
      }
    }
    return finalResult
  }


}


