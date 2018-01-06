//
//  QWPathTraceReader.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 07/05/16.
//  Copyright © 2016 XL Software Solutions. => MIT License
//

import Foundation

public protocol QWPathTraceReader {
  init(rootObject: QWRoot, qwPath: QWPath)
  func compareWithPreviousState(_ previousPathState: QWPathTraceReader?) -> (isDirty:Bool, description: String)
}

class QWPathTrace: QWPathTraceReader {

  let node: QWNodeState

  //Root object shall only be used during the initialisation of the chain, and not kept after
  required init(rootObject: QWRoot, qwPath: QWPath) {
    let prop = qwPath.root.descriptor
    self.node = QWNodeState(rootObject: rootObject, parentProp: prop, qwPath: qwPath)
  }

  func compareWithPreviousState(_ previousPathState: QWPathTraceReader?) -> (isDirty: Bool, description: String) {
    guard let previousPathState = previousPathState else {
      return (isDirty:true, description: "Node created")
    }
    if let chain = previousPathState as? QWPathTrace {
      return node.compareWithPreviousState(chain.node)
    }
    return (isDirty:true, description: "Different QWPathTraceReader type")
  }
}

class QWNodeState {

  // Capture an observable value of a monitored node or a child node

  // Capture qwCounterId
  var qwCounterId: NodeId

  // The MonitoredNode owner of the qwCounter shall be of type propertyDesc.sourceType
  let parentToMeProperty: QWPropertyID
  
  // If not a collection, nextNode point to the next element
  // If a collection, nodeCollection
  // The nextNodes[x].qwRoot shall be of type propertyDesc.sourceType

  // nextNodes contains the set of child nodes matching the signature
  var nextNodes: [QWNodeState] = []

  // childKeys contains the set of child properties matching the signature
  var childKeys: [QWPropertyID] = []


  // capture node change counter dictionary
  // for comparison with previous capture
  var changeCountDict: [AnyKeyPath:Int] = [:]

  // Root initialization
  convenience init(rootObject: QWRoot, parentProp: QWPropertyID, qwPath: QWPath)
  {
    let andAllChilds = qwPath.andAllChilds
    self.init(node: rootObject.getQWCounter(),
              propertyDesc: parentProp)
    self.readChain(qwPath.chain, fromMe:rootObject, andAllChilds: andAllChilds)
  }

  // Child init
  init(node: QWCounter, propertyDesc: QWPropertyID)
  {
    self.qwCounterId = node.nodeId
    self.changeCountDict = node.changeCountDict
    self.parentToMeProperty = propertyDesc
  }

  var count: Int {
    // = 1 (me) + sum of the next nodes count
    return nextNodes.map({$0.count}).reduce(1,+)
  }

  // ReadChain recursively reads the node tree, from parent to childs
  // The parent shall be a QWNode
  // the chain first element is the property leading from great-parent to parent
  //

  //TODO: add level counter
  func readChain(_ chain:[QWProperty], fromMe myNode: QWNode, andAllChilds: Bool)
  {
    let reducedChain = Array(chain.dropFirst())

//    let myChangeCounter = myNode.getQWCounter()
//    if (andAllChilds) {
//      Swift.print("ReadChain: Prop\(chain) node: \(myChangeCounter.changeCountDict)")
//    }

    var properties: [QWProperty] = []
    if let property = chain.first {
      properties = [property]
    } else if andAllChilds {
      properties = myNode.getPropertyArray()
    }

    for property in properties {
      if let _ = property.descriptor.propKey {
        self.childKeys.append(property.descriptor)
      }
      if property.isProperty {
        continue
      }

      let foundNodes: [QWNode] = property.getChildArray(node: myNode)
      // Item contains nodes
      for childNode in foundNodes {
        let childChangeCounter = childNode.getQWCounter()
        let nodeObserver = QWNodeState(node: childChangeCounter, propertyDesc: property.descriptor)
        nodeObserver.readChain(reducedChain, fromMe: childNode, andAllChilds: andAllChilds)
        self.nextNodes.append(nodeObserver)
      }
    }
  }
  
  
  func compareWithPreviousState(_ previousPathState: QWNodeState?) -> (isDirty:Bool, description: String)
  {

    guard let previousPathState = previousPathState else {
      return (isDirty:true, description: "Node created")
    }

    if (previousPathState.parentToMeProperty != self.parentToMeProperty) {
      assert(false,"Quantwm algorithm error")
    }

    let myDescription = parentToMeProperty.propDescription

    if (previousPathState.qwCounterId != self.qwCounterId) {
      return (isDirty:true, description: "Node \(myDescription) modified)")
    }

    // As the nodes are identical, check if node is dirty for the childKeys
    for childKey in childKeys {
      if previousPathState.changeCountDict[childKey.propKey!] != self.changeCountDict[childKey.propKey!] {
        return (isDirty:true, description: "Node \(myDescription) child \(childKey.propDescription) dirty")
      }
    }

    //TODO: Check if identical childKeys

    // On each refresh, a new set of nextNodes is created.
    // Let check if they are pointing the same set of monitored Nodes.
    // The order is not important here, because:
    // 1: getNodeAndDirtyFlag does not preserve the order
    // 2: is the order has changed, this is an array which was written to and
    //      the array value has changed. We already are dirty from previous check

    if previousPathState.nextNodes.count != self.nextNodes.count
    {
      return (isDirty:true, description: "Node Set \(myDescription) are different)")
    }

    let nodeCount = self.nextNodes.count
    if nodeCount == 0 {
      return (isDirty: false, description: "No change")
    }

    let compareNode  = { (node1:QWNodeState, node2:QWNodeState) -> Bool in
      if node1.parentToMeProperty == node2.parentToMeProperty {
        return node1.qwCounterId < node2.qwCounterId
      } else {
        return node1.parentToMeProperty.propDescription < node2.parentToMeProperty.propDescription
      }
    }

    let previousNodeArray = previousPathState.nextNodes.sorted(by: compareNode)
    let currentNodeArray  = self.nextNodes.sorted(by: compareNode)

    for index in 0..<nodeCount {
      let previousChildNode = previousNodeArray[index]
      let currentChildNode = currentNodeArray[index]
      if previousChildNode.parentToMeProperty == currentChildNode.parentToMeProperty {
        let result = currentChildNode.compareWithPreviousState(previousChildNode)
        if result.isDirty {
          return result
        }
      } else {
        return (isDirty:true, description: "Node Set \(myDescription) are different)")
      }
    }
    return (isDirty: false, description: "No change")
  }
}

