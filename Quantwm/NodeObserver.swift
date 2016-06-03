//
//  NodeObserver.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 07/05/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import Foundation



class NodeObserver {
  // Capture an observable value of a monitored node or a child node

  // Weak pointer to the node watcher, in order to monitor if the node was released
  weak var changeCounter: ChangeCounter?

  // The changeCounter.associatedObject shall be of type propertyDesc.sourceType
  let propertyDesc: PropertyDescription

  // If not a collection, nextNode point to the next element
  // If a collection, nodeCollection
  // The nextNodes[x].associatedObject shall be of type propertyDesc.sourceType
  var nextNodes: [NodeObserver]

  var firstNode: NodeObserver? {
    return nextNodes.first
  }
  // capture node change counter dictionary
  // for comparison with previous capture
  var changeCountDict: [String:Int] = [:]

  var childKey: String  {
    return propertyDesc.propKey
  }

  init(node: ChangeCounter, propertyDesc: PropertyDescription)
  {
    self.changeCounter = node
    self.changeCountDict = node.changeCountDict
    self.propertyDesc = propertyDesc
    self.nextNodes = []
  }

  init(node: ChangeCounter, propertyDesc: PropertyDescription, changeCount: [String:Int])
  {
    self.changeCounter = node
    self.changeCountDict = changeCount
    self.propertyDesc = propertyDesc
    self.nextNodes = []
  }

  var count: Int {
    // = 1 (me) + sum of the next nodes count
    return nextNodes.map({$0.count}).reduce(1,combine: +)
  }

  func readChain(chain:[PropertyDescription], fromParent parent: GenericNode) -> NodeObserver?
  {
    guard let property = chain.first else { return nil }
    let reducedChain = Array(chain.dropFirst())
    let nextProperty = reducedChain.first

    let node = parent.getNodeChangeCounter()
    let foundNodes = parent.getChildArray(property: property)
    if property.containsNodeCollection {
      // Item contains node
      self.nextNodes = []
      for monitoredNode in foundNodes {
        let childNode = monitoredNode.getNodeChangeCounter()
        if let nextProperty = nextProperty {
          let nodeObserver = NodeObserver(node: childNode, propertyDesc: nextProperty)
          nodeObserver.readChain(reducedChain, fromParent: monitoredNode)
          self.nextNodes.append(nodeObserver)
        }
      }
    } else if property.containsNode {

      // Item contains node
      if let monitoredNode = foundNodes.first {
        let childNode = monitoredNode.getNodeChangeCounter()
        if let nextProperty = nextProperty {
          let nodeObserver = NodeObserver(node: childNode, propertyDesc: nextProperty)
          nodeObserver.readChain(reducedChain, fromParent: monitoredNode)
          self.nextNodes.append(nodeObserver)
        }
      }
    } else {
      // Item contains value
      let nodeObserver = NodeObserver(node: node,
                                      propertyDesc: property,
                                      changeCount: node.changeCountDict)
      self.nextNodes = [nodeObserver]
    }
    return self
  }


  func compareWithPreviousChain(previousChain: NodeObserver?) -> (isDirty:Bool, description: String)
  {
    guard let previousChain = previousChain else {
      return (isDirty:true, description: "Node created")
    }

    // If previousChain exists, then at the previous refresh, the monitored node was not nil
    // If it is nil now, it has been released.
    if (previousChain.changeCounter == nil) {
      return (isDirty:true, description: "Node \(childKey) released)")
    }

    guard let changeCounter = self.changeCounter else {
      return (isDirty:true, description: "Node \(childKey) modified)")
    }

    // The monitored nodes are different ?
    if (previousChain.changeCounter  != changeCounter) {
      return (isDirty:true, description: "Node \(childKey) modified)")
    }

    // As the nodes are identical, check if node is dirty for the childKey
    if previousChain.changeCountDict[childKey] != self.changeCountDict[childKey] {
      if self.propertyDesc.containsNode
      {
        return (isDirty:true, description: "Node \(childKey) dirty")
      } else {
        return (isDirty:true, description: "Child \(childKey) dirty")
      }
    }

    if self.nextNodes.count > 1
    {
      // On each refresh, a new set of nextNodes is created.
      // Let check if they are pointing the same set of monitored Nodes.
      // The order is not important here, because:
      // 1: getNodeAndDirtyFlag does not preserve the order
      // 2: is the order has changed, this is an array which was written to and
      //      the array value has changed. We already are dirty from previous check
      let previousNodeArray = previousChain.nextNodes.flatMap({$0.changeCounter})
      let currentNodeArray  = self.nextNodes.flatMap({$0.changeCounter})
      // The pointed nodes are different
      if Set(currentNodeArray) != Set(previousNodeArray)
      {
        return (isDirty:true, description: "Node Set \(childKey) are different)")
      }
      // The occurence of pointed nodes are different
      if currentNodeArray.count != previousNodeArray.count
      {
        return (isDirty:true, description: "Node Set \(childKey) are different)")
      }

      var nonEmptyPreviousNodeArray = previousChain.nextNodes.filter({$0.changeCounter != nil})
      let nonEmptyCurrentNodeArray = self.nextNodes.filter({$0.changeCounter != nil})

      // Check 1 to 1 correspondance for non empty matching
      for nextNode in nonEmptyCurrentNodeArray {
        if let index = nonEmptyPreviousNodeArray.indexOf({$0.changeCounter == nextNode.changeCounter })
        {
          let matchingPreviousNode = nonEmptyPreviousNodeArray[index]
          let result = nextNode.compareWithPreviousChain(matchingPreviousNode)
          if result.isDirty {
            return result
          }
          nonEmptyPreviousNodeArray.removeAtIndex(index)
        } else {
          return (isDirty:true, description: "Node Set \(childKey) are different)")
        }
      }
    }
    else
    {
      if let nextNode = self.firstNode {
        return nextNode.compareWithPreviousChain(previousChain.firstNode)
      } else {
        if previousChain.firstNode != nil {
          return (isDirty:true, description: "Child \(previousChain.firstNode?.childKey) released)")
        }
      }
    }
    return (isDirty: false, description: "No change")
  }


  func collectNodeSet(inout nodeSet:Set<RW_Action>)
  {
    var action: RW_Action
    if let node = self.changeCounter {
      action = RW_Action(node: node, property: self.propertyDesc)
      nodeSet.insert(action)
      self.nextNodes.forEach({ $0.collectNodeSet(&nodeSet) })
    }
    else
    {
      action = RW_Action(emptyNodeWithProperty: self.propertyDesc)
      nodeSet.insert(action)
    }
  }
}
