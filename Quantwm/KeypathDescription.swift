//
//  KeypathDescription.swift
//  QUANTWM
//
//  Created by Xavier on 15/05/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import Foundation

class KeypathDescription: CustomDebugStringConvertible, Hashable, Equatable
{
    let root: PropertyDescription
    let chain: [PropertyDescription]

    // Set disableValidation to true if checkSourceTypeMatchesDestinationTypeOf fails to correctly
    // match the source and destination types between Objective-C and Swift
    init(root: PropertyDescription, chain: [PropertyDescription], disableValidation: Bool = false)
    {
        self.root = root
        self.chain = chain
        if !disableValidation {
            self.validate()
        }
    }

    var keypath: String {
        if let extensionPath = self.extensionPath {
            return root.propKey + "." + extensionPath
        } else {
            return root.propKey
        }
    }

    func key(index: Int)-> String? {
        if index == 0 {
            return root.propKey
        }
        let chainIndex = index - 1
        if (chainIndex >= 0) && (chainIndex < chain.count) {
            return chain[chainIndex].propKey
        }
        assert(true,"Error: Invalid index \(index) for \(keypath)")
        return nil
    }

    var rootPath: String {
        return root.propKey
    }

    var extensionPath: String? {
        if !chain.isEmpty {
            return chain.map({$0.propKey}).joinWithSeparator(".")
        } else {
            return nil
        }
    }

    func validate() -> Bool
    {
        if !root.isRoot {
            assert(false,"Error: \(root.description) is not a root element. Declare it with isRoot == true")
            return false
        }
        var previousProperty = root

        for property in chain {
            assert(previousProperty.containsNode,"Error: \(previousProperty.description) does not contains node" +
                " and is not the last element of the keypath")
            if !property.checkSourceTypeMatchesDestinationTypeOf(previousProperty: previousProperty) {
                assert(false,"Error: \(previousProperty.description) is declared of " +
                    "type \(previousProperty.dest) instead of type \(property.description)")
                return false
            }
            previousProperty = property
        }
        return true
    }

    var debugDescription: String {
        return "\(keypath)"
    }

    var hashValue: Int {
        return  root.hashValue &+ chain.reduce(0) {
            (cumulated: Int, prop: PropertyDescription) -> Int in
            return cumulated &+ prop.hashValue
        }
    }

    var level: Int {
        return chain.reduce(1, combine: PropertyDescription.maxLevelFunc)
    }

    var levelDescription: String {
        return chain.reduce("") {
            (current: String, prop: PropertyDescription) -> String in
            return current + ":\(prop.description)[\(prop.level)]"
        }
    }
}

func ==(lhs: KeypathDescription, rhs: KeypathDescription) -> Bool {
    let areEqual =
        lhs.root == rhs.root &&
            lhs.chain == rhs.chain
    return areEqual
}


