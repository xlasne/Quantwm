//
//  QWProperty.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 30/04/16.
//  Copyright  MIT License
//

import Foundation

// Used by QWNodeState
struct QWPropertyID: Equatable, Hashable {
  let propDescription: String
  let propKey: AnyKeyPath?
  let isNode: Bool

  var hashValue: Int {
    if let propKey = propKey {
      return propDescription.hashValue ^ isNode.hashValue ^ propKey.hashValue
    } else {
      return propDescription.hashValue ^ isNode.hashValue
    }
  }

}

func ==(lhs: QWPropertyID, rhs: QWPropertyID) -> Bool {
  return (lhs.propDescription == rhs.propDescription)
    && (lhs.propKey == rhs.propKey)
    && (lhs.isNode == rhs.isNode)
}

/// Root Data Model property.
/// Wraps the data model type and a String identifier
public class QWRootProperty: Equatable, Encodable
{

  // Codable for logging purpose only
  enum CodingKeys: String, CodingKey {
    case rootId
    case source
    case dest
  }


  var hashValue: Int {
    return self.descriptor.hashValue
  }

  // The rootId shall uniquely identify the QWRootProperty
  // during root registration.
  // Registering a new QWRootProperty with the same rootId replace the previous registration.
  let rootId: String
  let sourceType: Any.Type
  let source: String
  let destType: Any.Type
  let dest: String
  
  public init(
    rootType: Any.Type,
    rootId: String
    )
  {
    self.rootId = rootId
    self.sourceType = rootType
    self.destType = sourceType
    self.source = String(describing: sourceType)
    self.dest = String(describing: destType)
  }

  var descriptor:QWPropertyID {
    return QWPropertyID(propDescription: rootId, propKey: nil, isNode: true)
  }

  public static func ==(lhs: QWRootProperty, rhs: QWRootProperty) -> Bool {
    return lhs.descriptor == rhs.descriptor
  }

}

public class QWPropProperty<Root, Value>: QWProperty
  where Root: QWNode
{

  let getter: (Root) -> Value
  public init(
    propertyKeypath: KeyPath<Root,Value>,
    description: String)
    {
    self.getter = { (root: Root)->Value in
      return root[keyPath: propertyKeypath]
      }
    super.init(propertyKeypath: propertyKeypath, description: description)
  }
}

public class QWProperty: Hashable, Encodable
{

  // Codable for logging purpose only
  enum CodingKeys: String, CodingKey {
    case propDescription
    case source
    case dest
    case isNode
  }

  public var hashValue: Int {
    return propKey.hashValue ^ propDescription.hashValue
  }

  public static func ==(lhs: QWProperty, rhs: QWProperty) -> Bool {
    return lhs.propKey == rhs.propKey && lhs.propDescription == rhs.propDescription
  }

  let propKey: AnyKeyPath
  let propDescription: String
  let sourceType: Any.Type
  let source: String
  fileprivate(set) var destType: Any.Type
  fileprivate(set) var dest: String
  fileprivate(set) var isNode: Bool = false

  public func getChildArray(node:QWNode) -> [QWNode] {
    return []
  }

  var isProperty: Bool {
    return !isNode
  }

  var descriptor:QWPropertyID {
    return QWPropertyID(propDescription: propDescription, propKey: propKey, isNode: isNode)
  }

  public init<Root:QWNode, Value>(
    propertyKeypath: KeyPath<Root,Value>,
    description: String)
  {
    self.propKey = propertyKeypath
    self.propDescription = description
    self.sourceType = Root.self
    self.source = String(describing: sourceType)
    self.destType = Value.self
    self.dest = String(describing: destType)
  }

  // To be used by QWNodeProperty only
  // source and destination are overriden
  public init<Root:QWNode, Value>(anyKeypath: PartialKeyPath<Root>,
    description: String,
    rootType: Root.Type,
    destinationType: Value.Type)
  {
    self.propKey = anyKeypath
    self.propDescription = description
    self.sourceType = rootType
    self.source = String(describing: sourceType)
    self.destType = destinationType
    self.dest = String(describing: destType)
  }
}

public class QWNodeProperty: QWProperty
{

  // Codable for logging purpose only
  enum CodingKeys: String, CodingKey {
    case propDescription
    case source
    case dest
    case isNode
  }

  // If getChildArray is nil, this is a value descriptor (last keypath element)
  // else this is a ChildQWProperty
  public let getChildArrayClosure: ((QWNode) -> [QWNode])

  public override func getChildArray(node: QWNode) -> [QWNode] {
    return getChildArrayClosure(node)
  }

  override var descriptor:QWPropertyID {
    return QWPropertyID(propDescription: propDescription, propKey: propKey, isNode: self.isNode)
  }

  public init<Root:QWNode,Value:QWNode>(keypath: KeyPath<Root,Value?>,
                                        description: String)
  {
    self.getChildArrayClosure = {
      (root: QWNode) -> [QWNode] in
      if let root = root as? Root,
        let child = root[keyPath: keypath]
      {
        return [child]
      }
      return []
    }
    super.init(propertyKeypath: keypath, description: description)
    self.isNode = true
    self.destType = Value.self
    self.dest = String(describing: destType)
  }

  public init<Root:QWNode,Value:QWNode>(keypath: KeyPath<Root,Value>,
                                        description: String)
  {
    self.getChildArrayClosure = {
      (root: QWNode) -> [QWNode] in
      if let root = root as? Root {
        let child = root[keyPath: keypath]
        return [child]
      }
      return []
    }
    super.init(propertyKeypath: keypath, description: description)
    self.isNode = true
    self.destType = Value.self
    self.dest = String(describing: destType)
  }

  public init<Root:QWNode,Value:QWNode>(keypath: KeyPath<Root,[Value]>,
                                        description: String)
  {
    self.getChildArrayClosure = {
      (root: QWNode) -> [QWNode] in
      guard let root = root as? Root else { return[] }
      var result: [QWNode] = []
      let child = root[keyPath: keypath]
      for children in child {
        result.append(children)
      }
      return result
    }
    super.init(propertyKeypath: keypath, description: description)
    self.isNode = true
    self.destType = Value.self
    self.dest = String(describing: destType)
  }

  public init<Root:QWNode,Value:QWNode>(keypath: KeyPath<Root,Set<Value>>,
                                        description: String)
  {
    self.getChildArrayClosure = {
      (root: QWNode) -> [QWNode] in
      guard let root = root as? Root else { return[] }
      var result: [QWNode] = []
      let child = root[keyPath: keypath]
      for children in child {
        result.append(children)
      }
      return result
    }
    super.init(propertyKeypath: keypath, description: description)
    self.isNode = true
    self.destType = Value.self
    self.dest = String(describing: destType)
  }

  public init<Root:QWNode,Value:QWNode>(keypath: KeyPath<Root,[Value]?>,
                                        description: String)
  {
    self.getChildArrayClosure = {
      (root: QWNode) -> [QWNode] in
      guard let root = root as? Root else { return[] }
      var result: [QWNode] = []
      if let child = root[keyPath: keypath] {
        for children in child {
          result.append(children)
        }
      }
      return result
    }
    super.init(propertyKeypath: keypath, description: description)
    self.isNode = true
    self.destType = Value.self
    self.dest = String(describing: destType)

  }

  public init<Root:QWNode,Value:QWNode, Keys:Any>(keypath: KeyPath<Root,[Keys:Value]>,
                                        description: String)
  {
    self.getChildArrayClosure = {
      (root: QWNode) -> [QWNode] in
      guard let root = root as? Root else { return[] }
      var result: [QWNode] = []
      let childDict = root[keyPath: keypath] as [Keys:Value]
      let childs = childDict.values
      for children in childs {
        result.append(children)
      }
      return result
    }
    super.init(propertyKeypath: keypath, description: description)
    self.isNode = true
    self.destType = Value.self
    self.dest = String(describing: destType)

  }

  public init<Root:QWNode,Value:QWNode, Keys:Any>(keypath: KeyPath<Root,[Keys:Value]?>,
                                                  description: String)
  {
    self.getChildArrayClosure = {
      (root: QWNode) -> [QWNode] in
      guard let root = root as? Root else { return[] }
      var result: [QWNode] = []
      if let childs = root[keyPath: keypath]?.values {
        for children in childs {
          result.append(children)
        }
      }
      return result
    }
    super.init(propertyKeypath: keypath, description: description)
    self.isNode = true
    self.destType = Value.self
    self.dest = String(describing: destType)

  }

  public init<Root:QWNode,Value:QWNode>(
    keypath: PartialKeyPath<Root>,
    description: String,
    sourceType: Root.Type, destinationType: Value.Type,
    getHandler: @escaping (Root)->([Value]))
  {
    self.getChildArrayClosure = {
      (root: QWNode) -> [QWNode] in
      guard let root = root as? Root else { return[] }
      let values = getHandler(root)
      return values as [QWNode]
    }
    super.init(anyKeypath: keypath,
               description: description,
               rootType: sourceType,
               destinationType: destinationType)
    self.isNode = true
    self.destType = Value.self
    self.dest = String(describing: destType)
  }
}



