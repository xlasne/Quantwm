//
//  PropertyDescription.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 30/04/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import Foundation

// Quantwm 2
// A Root node is just a MonitoredNode
// A ChildNodeProperty is a keypath Keypath<Root,Value>
// or a Keypath<Root,Value?>
// or a Keypath<Root,[Value]?>
// or a Keypath<Root,[Value]>
// where Root and Value are MonitoredNode


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

open class RootDescriptor: NSObject
{

    let propDescription: String
    let sourceType: Any.Type
    let source: String
    let destType: Any.Type
    let dest: String

    public init(
        description: String,
        sourceType: Any.Type
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

open class PropertyDescriptor: NSObject
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
    let getChildArray: ((MonitoredNode) -> [MonitoredNode])?

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

    fileprivate init(
        keypath: AnyKeyPath,
        sourceType: Any.Type,
        destType: Any.Type,
        description: String,
        getChildArray: ((MonitoredNode) -> [MonitoredNode])?,
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

public class ChildPropertyDescriptor: PropertyDescriptor
{
    init(keypath: AnyKeyPath,
         description: String,
         sourceType: Any.Type,
         destType: Any.Type,
         getChildArray: @escaping (MonitoredNode) -> [MonitoredNode],
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

public class PropertyDescription<Root,Value>: ChildPropertyDescriptor
where Root: MonitoredNode, Value: MonitoredNode {

    init(keypath: KeyPath<Root,Value>,
         description: String,
         dependFromPropertySet: Set<PropertyDescriptor> = [])
    {
        let getChildArray = {
            (root: MonitoredNode) -> [MonitoredNode] in
            if let root = root as? Root {
                let child = root[keyPath: keypath]
                return [child]
            }
            return []
        }
        super.init(keypath: keypath,
                   description: description,
                   sourceType: Root.Type.self, destType: Value.Type.self,
                   getChildArray: getChildArray,
                   dependFromPropertySet: dependFromPropertySet)
    }

    init(keypath: WritableKeyPath<Root,Value?>,
         description: String,
         dependFromPropertySet: Set<PropertyDescriptor> = [])

    {
        let getChildArray = {
            (root: MonitoredNode) -> [MonitoredNode] in
            if let root = root as? Root,
                let child = root[keyPath: keypath]
            {
                return [child]
            }
            return []
        }
        super.init(keypath: keypath,
                   description: description,
                   sourceType: Root.Type.self, destType: Value.Type.self,
                   getChildArray: getChildArray,
                   dependFromPropertySet: dependFromPropertySet)
    }

    init(keypath: KeyPath<Root,Value?>,
         description: String,
         dependFromPropertySet: Set<PropertyDescriptor> = [])

    {
        let getChildArray = {
            (root: MonitoredNode) -> [MonitoredNode] in
            if let root = root as? Root,
                let child = root[keyPath: keypath]
            {
                return [child]
            }
            return []
        }
        super.init(keypath: keypath,
                   description: description,
                   sourceType: Root.Type.self, destType: Value.Type.self,
                   getChildArray: getChildArray,
                   dependFromPropertySet: dependFromPropertySet)
    }

    init(keypath: KeyPath<Root,[Value]>,
         description: String,
         dependFromPropertySet: Set<PropertyDescriptor> = [])
    {
        let getChildArray = {
            (root: MonitoredNode) -> [MonitoredNode] in
            guard let root = root as? Root else { return[] }
            var result: [MonitoredNode] = []
            let child = root[keyPath: keypath]
            for children in child {
                result.append(children)
            }
            return result
        }
        super.init(keypath: keypath,
                   description: description,
                   sourceType: Root.Type.self, destType: Value.Type.self,
                   getChildArray: getChildArray,
                   dependFromPropertySet: dependFromPropertySet)
    }

    init(keypath: KeyPath<Root,[Value]?>,
         description: String,
         dependFromPropertySet: Set<PropertyDescriptor> = [])
    {
        let getChildArray = {
            (root: MonitoredNode) -> [MonitoredNode] in
            guard let root = root as? Root else { return[] }
            var result: [MonitoredNode] = []
            if let child = root[keyPath: keypath] {
                for children in child {
                    result.append(children)
                }
            }
            return result
        }
        super.init(keypath: keypath,
                   description: description,
                   sourceType: Root.Type.self, destType: Value.Type.self,
                   getChildArray: getChildArray,
                   dependFromPropertySet: dependFromPropertySet)
    }

    func descriptor() -> ChildPropertyDescriptor {
        return ChildPropertyDescriptor(keypath: propKey,
                                  description: description,
                                  sourceType: sourceType,
                                  destType: destType,
                                  getChildArray: getChildArray!, // Shall be defined in all init
                                  dependFromPropertySet: dependFromPropertySet)
    }

}


//  public init(
//    swift_propKey: String,
//    sourceType: Any.Type,
//    destType: Any.Type,
//    option: PropertyDescriptionOption,
//    dependFromPropertySet: Set<PropertyDescription> = []
//    )
//  {
//    self.propKey = swift_propKey
//    self.sourceType = sourceType
//    self.source = String(describing: sourceType)
//    self.destType = destType
//    self.dest = String(describing: destType)
//    self.option = option
//    self.dependFromPropertySet = dependFromPropertySet
//    super.init()
//  }
//
//  public init(
//    objc_propKey: String,
//    sourceTypeStr: String,
//    destTypeStr: String?,
//    option: PropertyDescriptionOption,
//    dependFromPropertySet: Set<PropertyDescription> = []
//    )
//  {
//    self.propKey = objc_propKey
//    self.sourceType = nil
//    self.source = sourceTypeStr
//    self.destType = nil
//    self.dest = destTypeStr ?? ""
//    self.option = option
//    self.dependFromPropertySet = dependFromPropertySet
//    super.init()
//  }
//

//
//  open override var description: String {
//    return "\(source).\(propKey)"
//  }
//
//  var isRoot: Bool {
//    return option.contains(.isRoot)
//  }
//
//  var containsNode: Bool {
//    return option.contains(.containsNode) || option.contains(.containsNodeCollection)
//  }
//
//  var containsNodeCollection: Bool {
//    return option.contains(.containsNodeCollection)
//  }
//
//  var containsObjc: Bool {
//    return option.contains(.isObjectiveC)
//  }
//
//  var isMonitoredNodeGetter: Bool {
//    return option.contains(.monitoredNodeGetter)
//  }
//
//  static var maxLevelFunc: (_ currentMax: Int, _ otherProperty: PropertyDescription) -> Int =
//    {
//      (currentMax: Int, otherProperty: PropertyDescription) -> Int in
//      return max(currentMax, otherProperty.level)
//  }
//
//  var level: Int {
//    if dependFromPropertySet.isEmpty {
//      return 1
//    } else {
//      return dependFromPropertySet.reduce(1, PropertyDescription.maxLevelFunc) + 1
//    }
//  }
//}

//open class PropertyDescriptor<Source,Dest>
//{
//  open static func key(
//    _ key: String,
//    propertyDescriptionOption: PropertyDescriptionOption,
//    dependFromPropertySet: Set<PropertyDescription>
//    ) -> PropertyDescription
//  {
//    return PropertyDescription(swift_propKey: key,
//                               sourceType: Source.self,
//                               destType: Dest.self,
//                               option: propertyDescriptionOption,
//                               dependFromPropertySet: dependFromPropertySet
//    )
//  }
//
//    open static func key(
//        _ key: String,
//        propertyDescriptionOption: PropertyDescriptionOption
//        ) -> PropertyDescription
//    {
//        return PropertyDescription(swift_propKey: key,
//                                   sourceType: Source.self,
//                                   destType: Dest.self,
//                                   option: propertyDescriptionOption)
//    }
//
//    open static func key(
//        _ key: String) -> PropertyDescription
//    {
//        return PropertyDescription(swift_propKey: key,
//                                   sourceType: Source.self,
//                                   destType: Dest.self,
//                                   option: []
//        )
//    }
//}
//

//
//

