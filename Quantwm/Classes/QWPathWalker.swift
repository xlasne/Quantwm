//
//  QWPathWalker.swift
//  Quantwm
//
//  Created by Xavier on 16/12/2017.
//

import Foundation

// Objective: Apply QWCounterAccess state changes in the Model

// enum QWCounterAccess: Int {
//   case NoAccess         = 2   // Applied on all nodes before smart refresh
//   case ReadAccess       = 1   // Applied on nodes before write node in WritePath
//   case ReadWriteAccess  = 0   // or no Tag. Applied on Write nodes
//   case ReadOnlyAccess   = -1  // Applied on Observed Path
// }

class  QWPathWalker {

  static func applyNoAccessOnWholeTree(rootNode: QWRoot, tag: String) {
    QWTreeWalker.scanNodeTreeMap(fromParent: rootNode, closure: {
      (node:QWNode) -> () in
      node.getQWCounter().applyNoAccess(tag: tag)
    })
  }

  // levelVersusLastNode is negative before last chain node,
  // zero for last chain node, and positive after (andAllChilds = true)
  static func walkPath( rootNode: QWRoot, path: QWPath,
    closure:(_ node:QWNode,_ property: QWProperty, _ levelVersusLastNode:Int) -> ())
  {
    var chain = path.chain
    var currentNodes:[QWNode] = [rootNode]
    var levelVersusLastNode = -chain.count

    while currentNodes.count > 0 {
      let property = chain.first
      chain = Array(chain.dropFirst())
      levelVersusLastNode +=  1
      var nextNodes:[QWNode] = []

      for myNode in currentNodes {
        var properties: [QWProperty] = []
        if let property = property {
          properties = [property]
        } else if path.andAllChilds {
          properties = myNode.getPropertyArray()
        }

        for property in properties {
          closure(myNode, property, levelVersusLastNode)
          if property.isNode
          {
            let foundNodes: [QWNode] = property.getChildArray(node: myNode)
            // Item contains nodes
            for childNode in foundNodes {
              nextNodes.append(childNode)
            }
          }
        }
        currentNodes = nextNodes
      }
    }
  }

  static func applyWritePathAccess(rootNode: QWRoot, tag: String, path: QWPath) {
    QWPathWalker.walkPath(rootNode: rootNode, path: path) {
      (node:QWNode, property:QWProperty, level:Int) in
      if level < 0 {
        node.getQWCounter().applyReadAccess(keypath: property.propKey, tag: tag)
      } else {
        node.getQWCounter().applyWriteAccess(keypath: property.propKey, tag: tag)
      }
    }
  }

  static func applyObservedPathAccess(rootNode: QWRoot, tag: String, path: QWPath) {
    QWPathWalker.walkPath(rootNode: rootNode, path: path) {
      (node:QWNode, property:QWProperty, level:Int) in
      node.getQWCounter().applyReadOnlyAccess(keypath: property.propKey, tag: tag)
    }
  }

}
