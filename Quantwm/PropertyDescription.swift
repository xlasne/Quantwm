//
//  PropertyDescription.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 30/04/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import Foundation

// A Root node is just a MonitoredNode

open class RootDescriptor: NSObject
{
  // The propDescription shall uniquely identify the RootDescriptor
  // during root registration.
  // Registering a new RootDescriptor with the same propDescription replace the previous registration.
  let propDescription: String

  let sourceType: Any.Type
  let source: String
  let destType: Any.Type
  let dest: String
  
  public init(
    sourceType: Any.Type,
    description: String
    )
  {
    self.propDescription = description
    self.sourceType = sourceType
    self.destType = sourceType
    self.source = String(describing: sourceType)
    self.dest = String(describing: destType)
    super.init()
  }
}

@objc open class PropertyDescriptor: NSObject
{
  let propKey: AnyKeyPath
  let propDescription: String
  let sourceType: Any.Type
  let source: String
  let destType: Any.Type
  let dest: String
  let dependFromPropertySet: Set<PropertyDescriptor>
  
  // If getChildArray is nil, this is a value descriptor (last keypath element)
  // else this is a ChildPropertyDescriptor
  let getChildArray: ((QWMonitoredNode) -> [QWMonitoredNode])?
  
  public convenience init(
    keypath: AnyKeyPath,
    description: String
    )
  {
    self.init(keypath: keypath,
              description: description,
              dependFromPropertySet: [])
  }
  
  public init(
    keypath: AnyKeyPath,
    description: String,
    dependFromPropertySet: Set<PropertyDescriptor> = []
    )
  {
    self.propKey = keypath
    self.propDescription = description
    self.dependFromPropertySet = dependFromPropertySet
    self.sourceType = type(of: keypath).rootType.self
    self.destType = type(of: keypath).valueType.self
    self.source = String(describing: sourceType)
    self.dest = String(describing: destType)
    self.getChildArray = nil
    super.init()
  }
  
  public init(
    keypath: AnyKeyPath,
    sourceType: Any.Type,
    destType: Any.Type,
    description: String,
    getChildArray: ((QWMonitoredNode) -> [QWMonitoredNode])?,
    dependFromPropertySet: Set<PropertyDescriptor> = []
    )
  {
    self.propKey = keypath
    self.sourceType = sourceType
    self.destType = destType
    self.source = String(describing: sourceType)
    self.dest = String(describing: destType)
    self.propDescription = description
    self.getChildArray = getChildArray
    self.dependFromPropertySet = dependFromPropertySet
  }
  
  static var maxLevelFunc: (_ currentMax: Int, _ otherProperty: PropertyDescriptor) -> Int =
  {
    (currentMax: Int, otherProperty: PropertyDescriptor) -> Int in
    return max(currentMax, otherProperty.level)
  }
  
  var level: Int {
    if dependFromPropertySet.isEmpty {
      return 1
    } else {
      return dependFromPropertySet.reduce(1, PropertyDescriptor.maxLevelFunc) + 1
    }
  }
  
  func checkSourceTypeMatchesDestinationTypeOf(previousProperty: Any.Type) -> Bool
  {
    return source == String(describing: previousProperty)
  }
  
}

// A ChildNodeProperty is a keypath Keypath<Root,Value>
// or a Keypath<Root,Value?>
// or a Keypath<Root,[Value]?>
// or a Keypath<Root,[Value]>
// where Root and Value are MonitoredNode
// This class is used to initialize a
open class ChildPropertyDescriptor: PropertyDescriptor
{
  init(keypath: AnyKeyPath,
       description: String,
       sourceType: Any.Type,
       destType: Any.Type,
       getChildArray: @escaping (QWMonitoredNode) -> [QWMonitoredNode],
       dependFromPropertySet: Set<PropertyDescriptor>)
  {
    super.init(keypath: keypath,
               sourceType: sourceType,
               destType: destType,
               description: description,
               getChildArray: getChildArray,
               dependFromPropertySet: dependFromPropertySet)
  }
}

open class PropertyDescription<Root,Value>: ChildPropertyDescriptor
where Root: QWMonitoredNode, Value: QWMonitoredNode {
  
  public init(keypath: KeyPath<Root,Value>,
              description: String,
              dependFromPropertySet: Set<PropertyDescriptor> = [])
  {
    let getChildArray = {
      (root: QWMonitoredNode) -> [QWMonitoredNode] in
      if let root = root as? Root {
        let child = root[keyPath: keypath]
        return [child]
      }
      return []
    }
    super.init(keypath: keypath,
               description: description,
               sourceType: Root.self, destType: Value.self,
               getChildArray: getChildArray,
               dependFromPropertySet: dependFromPropertySet)
  }
  
  public init(keypath: KeyPath<Root,Value?>,
              description: String,
              dependFromPropertySet: Set<PropertyDescriptor> = [])
  {
    let getChildArray = {
      (root: QWMonitoredNode) -> [QWMonitoredNode] in
      if let root = root as? Root,
        let child = root[keyPath: keypath]
      {
        return [child]
      }
      return []
    }
    super.init(keypath: keypath,
               description: description,
               sourceType: Root.self, destType: Value.self,
               getChildArray: getChildArray,
               dependFromPropertySet: dependFromPropertySet)
  }
  
  public init(keypath: KeyPath<Root,[Value]>,
              description: String,
              dependFromPropertySet: Set<PropertyDescriptor> = [])
  {
    let getChildArray = {
      (root: QWMonitoredNode) -> [QWMonitoredNode] in
      guard let root = root as? Root else { return[] }
      var result: [QWMonitoredNode] = []
      let child = root[keyPath: keypath]
      for children in child {
        result.append(children)
      }
      return result
    }
    super.init(keypath: keypath,
               description: description,
               sourceType: Root.self, destType: Value.self,
               getChildArray: getChildArray,
               dependFromPropertySet: dependFromPropertySet)
  }
  
  public init(keypath: KeyPath<Root,[Value]?>,
              description: String,
              dependFromPropertySet: Set<PropertyDescriptor> = [])
  {
    let getChildArray = {
      (root: QWMonitoredNode) -> [QWMonitoredNode] in
      guard let root = root as? Root else { return[] }
      var result: [QWMonitoredNode] = []
      if let child = root[keyPath: keypath] {
        for children in child {
          result.append(children)
        }
      }
      return result
    }
    super.init(keypath: keypath,
               description: description,
               sourceType: Root.self, destType: Value.self,
               getChildArray: getChildArray,
               dependFromPropertySet: dependFromPropertySet)
  }
  
  public func descriptor() -> ChildPropertyDescriptor {
    return ChildPropertyDescriptor(keypath: propKey,
                                   description: description,
                                   sourceType: sourceType,
                                   destType: destType,
                                   getChildArray: getChildArray!, // Shall be defined in all init
      dependFromPropertySet: dependFromPropertySet)
  }
  
}



