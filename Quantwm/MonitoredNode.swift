//
//  MonitoredNode.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 10/05/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

// Problem:

// Get Swift MonitoredNode from ObjectiveC NSObject parent
// Get Swift MonitoredNode from Swift MonitoredNode parent
// Get Swift Object Watcher from ObjectiveC parent
// Get Swift Object Watcher from Swift MonitoredNode parent

// Manage Swift child with protocol compliance
// ObjectiveC child with keyValue introspection

// Perform all the job from swift side

// On return:
// If Swift child, return MonitoredNode
// If Objective-C child, return NSObject

// Build NodeObserver hierarchy
// NodeObserver points toward ChangeCounter objects (common to Swift and ObjectiveC)


import Foundation

enum GenericNode {
  case objectType(NSObject)
  case monitoredNodeType(MonitoredNode)

  func getNodeChangeCounter() -> ChangeCounter
  {
    switch self {
    case .objectType(let myObject):
      return MonitoredNodeObjcParser.getNodeChangeCounter(myObject)
    case .monitoredNodeType(let myNode):
      return myNode.getNodeChangeCounter()
    }
  }

  func getChildArray(property: PropertyDescription) -> [GenericNode]
  {
    switch self {
    case .objectType(let myObject):
      if property.containsObjc {
        let objectArray: [NSObject] = MonitoredNodeObjcParser.getChildArray(property: property, node: myObject)
        return objectArray.map({GenericNode.objectType($0)})
      } else {
        let objectArray: [MonitoredNode] = MonitoredNodeObjcParser.getChildArray(property: property, node: myObject)
        return objectArray.map({GenericNode.monitoredNodeType($0)})
      }
    case .monitoredNodeType(let myNode):
      if property.containsObjc {
        let objectArray: [NSObject] = myNode.getChildArray(property: property)
        return objectArray.map({GenericNode.objectType($0)})
      } else {
        if property.isMonitoredNodeGetter {
          if let myGetterNode = myNode as? MonitoredNodeGetter {
            let objectArray = myGetterNode.getMonitoredNodeArray(property)
            return objectArray.map({GenericNode.monitoredNodeType($0)})
          } else {
            assert(false,"Error: Object type \(property.source) is not conformant to protocol MonitoredNodeGetter")
            return []
          }
        } else {
          let objectArray: [MonitoredNode] = myNode.getChildArray(property: property)
          return objectArray.map({GenericNode.monitoredNodeType($0)})
        }
      }
    }
  }
}

public protocol MonitoredNodeGetter
{
  func getMonitoredNodeArray(_ property: PropertyDescription) -> [MonitoredNode]
}

public protocol MonitoredClass: class, MonitoredNode  // class is required only to have weak pointers to object
{
}

public typealias MonitoredStruct = MonitoredNode

public protocol MonitoredNode: SwiftKVC
{
  func getNodeChangeCounter() -> ChangeCounter
  func getChildArray<T>(property: PropertyDescription) -> [T]
}


public extension MonitoredNode
{
  public func getNodeChangeCounter() -> ChangeCounter
  {
    if let nodeValue = self.KVC_valueForKeyPath("changeCounter") as? ChangeCounter
    {
      return nodeValue
    } else {
        assert(false,"KeyNodeCodable: Class \(type(of: self)) is configured with MonitoredNode, but does not contains changeCounter:ChangeCounter property")
        return ChangeCounter()
    }
  }

  public func getChildArray<T>(property: PropertyDescription) -> [T]
  {
    // The child shall be an object or a struct
    // which contains a changeCounter: ChangeCounter object
    // First, check if a value exist

    let childKey = property.propKey
    let childCheck = self.KVC_valueExistForKey(childKey)
    assert(childCheck.exist,"ChangeCounter: MonitoredChild \(childKey) not found")

    // Then, find the child node if present
    if childCheck.isSome
    {
      if property.containsNodeCollection {
        var result : [T] = []
        if let value = self.KVC_valueForKeyPath(childKey)
        {
          let mirror = Mirror(reflecting: value)
          for child in mirror.children {
            if let parent = child.value as? T {
              result.append(parent)
            } else {
              assert(false,"KVC_NodeArrayForKey: Child array \(childKey) is not a collection of MonitoredNode")
            }
          }
        }
        return result
      }

      if property.containsNode {
        if let childValue = self.KVC_valueForKeyPath(childKey) as? T
        {
          return [childValue]
        } else {
          assert(childCheck.exist,"ChangeCounter: MonitoredChild \(childKey) is configured with containsNode = true, but does not contains a changeCounter: ChangeCounter")
        }
      } else {
        return []
      }
    }
    return []
  }
}

class MonitoredNodeObjcParser
{
  static func getNodeChangeCounter(_ node: NSObject) -> ChangeCounter
  {
    if let nodeValue = node.value(forKey: "changeCounter") as? ChangeCounter
    {
        return nodeValue
    } else {
        assert(false,"MonitoredNode: Objective-C Class \(type(of: node)) is configured with containsNode, but does not contains changeCounter:ChangeCounter property")
        return ChangeCounter()
    }
  }

  static func getChildArray<T>(property: PropertyDescription, node: NSObject) -> [T]
  {
    // The child shall be an object or a struct
    // which contains a changeCounter: ChangeCounter object
    // First, check if a value exist

    let childKey = property.propKey
    guard let childValue = node.value(forKey: childKey) else {
      // shall I assert here ?
      return  []
    }

    if property.containsNodeCollection {
      if let arrayValue = childValue as? [T]
      {
        return arrayValue
      } else {
        assert(false,"KVC_NodeArrayForKey: Child array \(childKey) is not a collection of MonitoredNode")
      }
    }

    if property.containsNode {
      if let childValue = node.value(forKey: childKey) as? T
      {
        return [childValue]
      } else {
        assert(false,"ChangeCounter: MonitoredChild \(childKey) is configured with containsNode = true, but does not contains a changeCounter: ChangeCounter")
      }
    }
    return  []
  }
}
