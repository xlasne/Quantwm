//
//  KeypathDescription.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 15/05/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import Foundation

open class KeypathSet
{
  open var readKeypathSet : Set<KeypathDescription> = []
  open var writtenPropertySet: Set<PropertyDescriptor> = []
  
  public init()
  { }
  
  public init(readWithRoot root: RootDescriptor, chain: [PropertyDescriptor], disableValidation: Bool = false)
  {
    let keypathDesc = KeypathDescription(root: root, chain: chain, disableValidation: disableValidation)
    readKeypathSet = [keypathDesc]
  }
  
  open func addRead(root: RootDescriptor, chain: [PropertyDescriptor], disableValidation: Bool = false)
  {
    let keypathDesc = KeypathDescription(root: root, chain: chain, disableValidation: disableValidation)
    readKeypathSet.insert(keypathDesc)
  }
  
  open func addWrittenProperty(_ property: PropertyDescriptor)
  {
    writtenPropertySet.insert(property)
  }
}

public func +(lhs: KeypathSet, rhs: KeypathSet) -> KeypathSet
{
  let keypathSet = KeypathSet()
  for item in lhs.readKeypathSet { keypathSet.readKeypathSet.insert(item)}
  for item in rhs.readKeypathSet { keypathSet.readKeypathSet.insert(item)}
  for item in lhs.writtenPropertySet { keypathSet.writtenPropertySet.insert(item)}
  for item in rhs.writtenPropertySet { keypathSet.writtenPropertySet.insert(item)}
  return keypathSet
}


open class KeypathDescription: CustomDebugStringConvertible, Hashable, Equatable
{
  let root: RootDescriptor
  let chain: [PropertyDescriptor]
  
  // Set disableValidation to true if checkSourceTypeMatchesDestinationTypeOf fails to correctly
  // match the source and destination types between Objective-C and Swift
  public init(root: RootDescriptor, chain: [PropertyDescriptor], disableValidation: Bool = false)
  {
    self.root = root
    self.chain = chain
    if !disableValidation {
      let _ = self.validate()
    }
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
    assert(true,"Error: Invalid index \(index) for \(keypath)")
    return nil
  }
  
  var rootPath: String {
    return root.propDescription
  }
  
  var extensionPath: String? {
    if !chain.isEmpty {
      return chain.map({$0.propDescription}).joined(separator: ".")
    } else {
      return nil
    }
  }
  
  func validate() -> Bool
  {
        var previousProperty = root.sourceType

        for property in chain {
    //      assert(previousProperty.containsNode,"Error: \(previousProperty.description) does not contains node" +
    //        " and is not the last element of the keypath")
          if !property.checkSourceTypeMatchesDestinationTypeOf(previousProperty: previousProperty) {
            assert(false,"Error: \(previousProperty) is declared of " +
              "type \(previousProperty) instead of type \(property.source)")
            return false
          }
            previousProperty = property.destType
        }
    return true
  }
  
  open var debugDescription: String {
    return "\(keypath)"
  }
  
  open var hashValue: Int {
    return  root.hashValue &+ chain.reduce(0) {
      (cumulated: Int, prop: PropertyDescriptor) -> Int in
      return cumulated &+ prop.hashValue
    }
  }
  
  var level: Int {
    return chain.reduce(1, PropertyDescriptor.maxLevelFunc)
  }
  
  var levelDescription: String {
    return chain.reduce("") {
      (current: String, prop: PropertyDescriptor) -> String in
      return current + ":\(prop.propDescription)[\(prop.level)]"
    }
  }
}

public func ==(lhs: KeypathDescription, rhs: KeypathDescription) -> Bool {
  let areEqual =
    lhs.root == rhs.root &&
      lhs.chain == rhs.chain
  return areEqual
}


