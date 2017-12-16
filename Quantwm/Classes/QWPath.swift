//
//  QWPath.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 15/05/16.
//  Copyright © 2016 XL Software Solutions. => MIT License
//

import Foundation

public struct QWPath: CustomDebugStringConvertible, Hashable, Equatable, Encodable
{

  // Codable for logging purpose only
  enum CodingKeys: String, CodingKey {
    case root
    case chain
    case andAllChilds
    case type
  }

  enum QWPathType: Int, Codable {
    case node
    case property
    case tree
  }

  enum QWAccess: Int, Codable {
    case readPath
    case writePath
  }

  let root: QWRootProperty
  let chain: [QWProperty]
  let andAllChilds: Bool
  let type: QWPathType
  let access: QWAccess

  public init(root: QWRootProperty)
  {
    self.root = root
    self.chain = []
    self.andAllChilds = false
    self.type = .node
    self.access = .readPath
  }

  // Set andAllChilds to true if checkSourceTypeMatchesDestinationTypeOf fails to correctly
  // match the source and destination types between Objective-C and Swift
  fileprivate init(root: QWRootProperty, chain: [QWProperty], andAllChilds: Bool = false, access: QWAccess)
  {
    self.root = root
    self.chain = chain
    self.andAllChilds = andAllChilds
    self.access = access

    if andAllChilds {
      self.type = .tree
    } else {
      if let isProp = chain.last?.isProperty {
        self.type = isProp ? .property : .node
      } else {
        self.type = .node
      }
    }
  }

  public var map: QWMap {
    return QWMap(path: self)
  }
  
  var keypath: String {
    if let extensionPath = self.extensionPath {
      return root.propDescription + "." + extensionPath
    } else {
      return root.propDescription
    }
  }
  
  func key(_ index: Int)-> String? {
    if index == 0 {
      return root.propDescription
    }
    let chainIndex = index - 1
    if (chainIndex >= 0) && (chainIndex < chain.count) {
      return chain[chainIndex].propDescription
    }
    assert(false,"Error: Invalid index \(index) for \(keypath)")
    return nil
  }
  
  var rootPath: String {
    return root.propDescription
  }
  
  var extensionPath: String? {
    if !chain.isEmpty {
      var res = chain.map({$0.propDescription}).joined(separator: ".")
      if andAllChilds {
        res.append(".All")
      }
      return res
    } else {
      if andAllChilds {
        return ".All"
      }
      return nil
    }
  }
  

  public var debugDescription: String {
    return "\(keypath)"
  }
  
  public var hashValue: Int {
    return  root.hashValue &+ chain.reduce(0) {
      (cumulated: Int, prop: QWProperty) -> Int in
      return cumulated &+ prop.hashValue
    }
  }
  
  var levelDescription: String {
    return chain.reduce("") {
      (current: String, prop: QWProperty) -> String in
      return current + ":\(prop.propDescription)"
    }
  }

  public func appending(_ chainElement: QWProperty) -> QWPath {
    // Shall I disable this test in release mode ?
    switch self.type
    {
    case .tree:
      preconditionFailure("Error QWPath: Adding \(chainElement.propDescription) on a subtree QWPath \(keypath)")
    case .property:
      preconditionFailure("Error QWPath: Adding \(chainElement.propDescription) on a property QWPath \(keypath)")
    case .node:
      break
    }
    let _ = validate(newElement: chainElement)
    return QWPath(root: self.root,
                  chain: self.chain + [chainElement],
                  andAllChilds: false,
                  access: access) as QWPath
  }

  func validate(newElement: QWProperty) -> Bool
  {
    let previousProperty: Any.Type = chain.last?.destType ?? root.sourceType
    return newElement.checkSourceTypeMatchesDestinationTypeOf(previousProperty: previousProperty)
  }

  public func all() -> QWPath {
    switch self.type
    {
    case .tree:
      print("Warning QWPath: Adding all() on a subtree QWPath \(keypath)")
    case .property:
      preconditionFailure("Error QWPath: Adding all() on a property QWPath \(keypath)")
    case .node:
      break
    }
    return QWPath(root: self.root,
                  chain: self.chain,
                  andAllChilds: true,
                  access: access) as QWPath
  }

  public func write() -> QWPath {
    return QWPath(root: root,
                  chain: chain,
                  andAllChilds: andAllChilds,
                  access: .writePath)
  }
}

// Access is only for debug on registration, and is not usefull for equality
public func ==(lhs: QWPath, rhs: QWPath) -> Bool {
  let areEqual =
    lhs.root == rhs.root &&
      lhs.chain == rhs.chain &&
      lhs.andAllChilds == rhs.andAllChilds
  return areEqual
}

extension QWPath // Property and Node Getter
{

//  public func generateCollectionPropertyGetter<Root,Value>(property: QWPropProperty<Root,Value>) -> (QWRoot) -> [Value]{
//    switch self.type
//    {
//    case .property:
//      preconditionFailure("Error QWPath: Calling generatePropertyGetter on a property QWPath \(keypath)")
//    case .tree:
//      break
//    case .node:
//      break
//    }
//
//    let myChain = self.chain
//    let getter:(QWRoot) -> [Value] = { (root:QWRoot) -> [Value] in
//      var currentNodeArray:[QWNode] = [root]
//      for prop in myChain {
//        if !prop.isProperty {
//          var nextNodeArray:[QWNode] = []
//          for myNode in currentNodeArray {
//            let foundNodes: [QWNode] = prop.getChildArray(node: myNode)
//            nextNodeArray += foundNodes
//          }
//          currentNodeArray = nextNodeArray
//        }
//      }
//      var finalPropArray:[Value] = []
//      for item in currentNodeArray {
//        let item = item as! Root
//        let value = property.getter(item)
//        finalPropArray.append(value)
//      }
//      return finalPropArray
//    }
//    return getter
//  }
//
//  public func generatePropertyGetter<Root,Value>(property: QWPropProperty<Root,Value>) -> (QWRoot) -> Value? {
//    switch self.type
//    {
//    case .property:
//      preconditionFailure("Error QWPath: Calling generatePropertyGetter on a property QWPath \(keypath)")
//    case .tree:
//      break
//    case .node:
//      break
//    }
//
//    let myChain = self.chain
//    let getter:(QWRoot) -> Value? = { (root:QWRoot) -> Value? in
//      var currentNode:QWNode? = root
//      for property in myChain {
//        if let node = currentNode {
//          if !property.isProperty {
//            var nextNodeArray:[QWNode] = []
//            let foundNodes: [QWNode] = property.getChildArray(node: node)
//            nextNodeArray += foundNodes
//            if nextNodeArray.count > 1 {
//              preconditionFailure("Error: Using single getter on multipath. Add the sourcery: multi option on the collection property in the path: \(myChain)")
//            }
//            currentNode = nextNodeArray.first
//          }
//        }
//      }
//      if let node = currentNode as? Root {
//        let value = property.getter(node)
//        return value
//      }
//      return nil
//    }
//    return getter
//  }

//  public func generateCollectionNodeGetter() -> (QWRoot) -> [QWNode]{
//    let myChain = chain
//    let getter:(QWRoot) -> [QWNode] = { (root:QWRoot) -> [QWNode] in
//      var currentNodeArray:[QWNode] = [root]
//      for property in myChain {
//        if !property.isProperty {
//          var nextNodeArray:[QWNode] = []
//          for myNode in currentNodeArray {
//            let foundNodes: [QWNode] = property.getChildArray(node: myNode)
//            nextNodeArray += foundNodes
//          }
//          currentNodeArray = nextNodeArray
//        }
//      }
//      return currentNodeArray
//    }
//    return getter
//  }
//
//  public func generateNodeGetter() -> (QWRoot) -> QWNode?{
//    let myChain = chain
//    let getter:(QWRoot) -> QWNode? = { (root:QWRoot) -> QWNode? in
//      var currentNode:QWNode? = root
//      for property in myChain {
//        if let node = currentNode {
//          if !property.isProperty {
//            var nextNodeArray:[QWNode] = []
//            let foundNodes: [QWNode] = property.getChildArray(node: node)
//            nextNodeArray += foundNodes
//            if nextNodeArray.count > 1 {
//              preconditionFailure("Error: Using single getter on multipath. Add the sourcery: multi option on the collection property in the path: \(myChain)")
//            }
//            currentNode = nextNodeArray.first
//          }
//        }
//      }
//      return currentNode
//    }
//    return getter
//  }

}



