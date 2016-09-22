//
//  PropertyDescription.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 30/04/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import Foundation

//public struct PropertyDescriptionOption : OptionSetType
//{
//    public let rawValue : Int
//    public init(rawValue:Int) {
//        self.rawValue = rawValue
//    }
//
//    static let ContainsNode           = PropertyDescriptionOption(rawValue:1)
//    static let ContainsNodeCollection = PropertyDescriptionOption(rawValue:2)
//    static let IsRoot                 = PropertyDescriptionOption(rawValue:4)
//}


// source and destination type are only present to perform chain type checking
// value type leaf destination is thus optional


@objc open class PropertyDescription: NSObject
{
  open let propKey: String
  let sourceType: Any.Type?
  let destType: Any.Type?
  let source: String
  let dest: String
  let option: PropertyDescriptionOption
  let dependFromPropertySet: Set<PropertyDescription>

  public init(
    swift_propKey: String,
    sourceType: Any.Type,
    destType: Any.Type,
    option: PropertyDescriptionOption,
    dependFromPropertySet: Set<PropertyDescription> = []
    )
  {
    self.propKey = swift_propKey
    self.sourceType = sourceType
    self.source = String(describing: sourceType)
    self.destType = destType
    self.dest = String(describing: destType)
    self.option = option
    self.dependFromPropertySet = dependFromPropertySet
    super.init()
  }

  public init(
    objc_propKey: String,
    sourceTypeStr: String,
    destTypeStr: String?,
    option: PropertyDescriptionOption,
    dependFromPropertySet: Set<PropertyDescription> = []
    )
  {
    self.propKey = objc_propKey
    self.sourceType = nil
    self.source = sourceTypeStr
    self.destType = nil
    self.dest = destTypeStr ?? ""
    self.option = option
    self.dependFromPropertySet = dependFromPropertySet
    super.init()
  }

  func checkSourceTypeMatchesDestinationTypeOf(previousProperty:PropertyDescription) -> Bool
  {
    // Check on Swift only AnyType
    if let sourceType = self.sourceType,
      let destType = previousProperty.destType {
      return sourceType == destType
    }
    // Else check the string value of type for Objective-C.
    // TODO: I do not know if this really work. Help welcome to validate this.
    return previousProperty.dest == self.source
  }

  open override var description: String {
    return "\(source).\(propKey)"
  }

  var isRoot: Bool {
    return option.contains(.isRoot)
  }

  var containsNode: Bool {
    return option.contains(.containsNode) || option.contains(.containsNodeCollection)
  }

  var containsNodeCollection: Bool {
    return option.contains(.containsNodeCollection)
  }

  var containsObjc: Bool {
    return option.contains(.isObjectiveC)
  }

  var isMonitoredNodeGetter: Bool {
    return option.contains(.monitoredNodeGetter)
  }

  static var maxLevelFunc: (_ currentMax: Int, _ otherProperty: PropertyDescription) -> Int =
    {
      (currentMax: Int, otherProperty: PropertyDescription) -> Int in
      return max(currentMax, otherProperty.level)
  }

  var level: Int {
    if dependFromPropertySet.isEmpty {
      return 1
    } else {
      return dependFromPropertySet.reduce(1, PropertyDescription.maxLevelFunc) + 1
    }
  }
}

open class PropertyDescriptor<Source,Dest>
{
  open static func key(
    _ key: String,
    propertyDescriptionOption: PropertyDescriptionOption = [],
    dependFromPropertySet: Set<PropertyDescription> = []
    ) -> PropertyDescription
  {
    return PropertyDescription(swift_propKey: key,
                               sourceType: Source.self,
                               destType: Dest.self,
                               option: propertyDescriptionOption,
                               dependFromPropertySet: dependFromPropertySet
    )
  }
}

open class RootDescriptor<Source>
{
  open static func key(_ key: String) -> PropertyDescription
  {
    return PropertyDescription(swift_propKey: key,
                               sourceType: Source.self,
                               destType: Source.self,
                               option: [.containsNode, .isRoot])
  }
}



