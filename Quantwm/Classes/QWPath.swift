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
  }


  let root: QWRootProperty
  let chain: [QWProperty]
  var andAllChilds: Bool
  
  // Set andAllChilds to true if checkSourceTypeMatchesDestinationTypeOf fails to correctly
  // match the source and destination types between Objective-C and Swift
  public init(root: QWRootProperty, chain: [QWProperty], andAllChilds: Bool = false)
  {
    self.root = root
    self.chain = chain
    self.andAllChilds = andAllChilds

    if QUANTUM_MVVM_DEBUG == true {
      self.validate()
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
  
  func validate()
  {
    var previousProperty = root.sourceType
    for property in chain {
      property.checkSourceTypeMatchesDestinationTypeOf(previousProperty: previousProperty)
      previousProperty = property.destType
    }

    // All properties shall be Node is andAllChild is true
    // All properties but the last shall be Node is andAllChild is false
    for (index,prop) in chain.enumerated() {
      if (index < chain.count-1) || andAllChilds {
        assert(prop.isNode,"Error: \(prop) in \(self.levelDescription) shall be a QWNodeProperty")
      }
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

  public func appending(_ chainElement: QWProperty, andAllChilds: Bool = false) -> QWPath {
    let extendedChain = self.chain + [chainElement]
    return QWPath(root: self.root,
                              chain: extendedChain,
                              andAllChilds: andAllChilds)
  }

  public func all() -> QWPath {
    return QWPath(root: self.root,
                  chain: self.chain,
                  andAllChilds: true)
  }

}

public func ==(lhs: QWPath, rhs: QWPath) -> Bool {
  let areEqual =
    lhs.root == rhs.root &&
      lhs.chain == rhs.chain &&
    lhs.andAllChilds == rhs.andAllChilds
  return areEqual
}


