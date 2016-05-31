//
//  PropertyDescription.swift
//  QUANTWM
//
//  Created by Xavier on 30/04/16.
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


@objc class PropertyDescription: NSObject
{
    let propKey: String
    let sourceType: Any.Type?
    let destType: Any.Type?
    let source: String
    let dest: String
    let option: PropertyDescriptionOption
    let dependFromPropertySet: Set<PropertyDescription>

    init(swift_propKey: String, sourceType: Any.Type, destType: Any.Type, option: PropertyDescriptionOption,
         dependFromPropertySet: Set<PropertyDescription> = [])
    {
        self.propKey = swift_propKey
        self.sourceType = sourceType
        self.source = String(sourceType)
        self.destType = destType
        self.dest = String(destType)
        self.option = option
        self.dependFromPropertySet = dependFromPropertySet
    }

    init(objc_propKey: String, sourceTypeStr: String, destTypeStr: String?, option: PropertyDescriptionOption,
         dependFromPropertySet: Set<PropertyDescription> = [])
    {
        self.propKey = objc_propKey
        self.sourceType = nil
        self.source = sourceTypeStr
        self.destType = nil
        self.dest = destTypeStr ?? ""
        self.option = option
        self.dependFromPropertySet = dependFromPropertySet
    }

    func checkSourceTypeMatchesDestinationTypeOf(previousProperty previousProperty:PropertyDescription) -> Bool
    {
        // Check on Swift only AnyType
        if let sourceType = self.sourceType,
            let destType = previousProperty.destType {
            return sourceType == destType
        }
        // Else check the string value of type.
        // I do not know if this really work ..
        return previousProperty.dest == self.source
    }

    override var description: String {
        return "\(source).\(propKey)"
    }

    var isRoot: Bool {
        return option.contains(.IsRoot)
    }

    var containsNode: Bool {
        return option.contains(.ContainsNode) || option.contains(.ContainsNodeCollection)
    }

    var containsNodeCollection: Bool {
        return option.contains(.ContainsNodeCollection)
    }

    var containsObjc: Bool {
        return option.contains(.IsObjectiveC)
    }

    static var maxLevelFunc: (currentMax: Int, otherProperty: PropertyDescription) -> Int =
        {
            (currentMax: Int, otherProperty: PropertyDescription) -> Int in
            return max(currentMax, otherProperty.level)
        }

    var level: Int {
        if dependFromPropertySet.isEmpty {
            return 1
        } else {
            return dependFromPropertySet.reduce(1, combine: PropertyDescription.maxLevelFunc) + 1
        }
    }
}

class PropertyDescriptor<Source,Dest>
{
    static func key(key: String, propertyDescriptionOption: PropertyDescriptionOption = [],
                    dependFromPropertySet: Set<PropertyDescription> = []) -> PropertyDescription
    {
        return PropertyDescription(swift_propKey: key,
                             sourceType: Source.self,
                             destType: Dest.self,
                             option: propertyDescriptionOption,
                             dependFromPropertySet: dependFromPropertySet)
    }
}

class RootDescriptor<Source>
{
    static func key(key: String) -> PropertyDescription
    {
        return PropertyDescription(swift_propKey: key,
                             sourceType: Source.self,
                             destType: Source.self,
                             option: [.ContainsNode, .IsRoot])
    }
}



