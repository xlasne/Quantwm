//
// SwiftKVC - Defines a mechanism by which you can access 
// the properties of an object indirectly by name (or key), 
// rather than directly through invocation of an accessor method or as instance variables.
//
//
//  Updated by Xavier on 23/04/16.
//  From github : leemorgan/SwiftKVC
//

import Foundation

typealias ParentAndNode = (parent: SwiftKVC, node: ChangeCounter)


protocol SwiftKVC
{
    func KVC_valueExistForKey(key : String) -> (exist:Bool, isOptional: Bool?, isSome: Bool)
    func KVC_valueForKey(key : String) -> Any?
    func KVC_valueForKeyPath(keyPath : String) -> Any?
    subscript (KVC_key key: String) -> Any? { get }
}

extension SwiftKVC {

    func KVC_valueExistForKey(key : String) -> (exist:Bool, isOptional: Bool?, isSome: Bool) {
        let mirror = Mirror(reflecting: self)
        for myChild in mirror.children {
            if myChild.label == key {
                if myChild.value is OptionalProtocol
                {
                    if let optChild = myChild.value as? OptionalProtocol {
                        return (exist:true, isOptional: true, isSome: optChild.isSome())
                    }
                }
                else
                {
                    return (exist:true, isOptional: false, isSome: true)
                }
            }
        }
        return (exist:false, isOptional: nil, isSome: false)
    }

    /// Returns the value for the property identified by a given key.
    func KVC_valueForKey(key : String) -> Any? {

        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if (child.label == key) || (child.label == key + ".storage") {
                return child.value
            }
        }
        return nil
    }

    /// Returns the value for the derived property identified by a given key path.
    func KVC_valueForKeyPath(keyPath : String) -> Any? {
        let keys = keyPath.componentsSeparatedByString(".")
        var mirror = Mirror(reflecting: self)
        for key in keys {
            for child in mirror.children {
                if (child.label == key) ||
                    (child.label == key + ".storage")  // Case of Lazy initialization
                {           //
                    if child.value is OptionalProtocol
                    {
                        if let optChild = child.value as? OptionalProtocol {
                            if optChild.isSome()
                            {
                                let unwrapped = optChild.unwrap()
                                if key == keys.last {
                                    return unwrapped
                                } else {
                                    mirror = Mirror(reflecting: unwrapped)
                                    break
                                }
                            } else {
                                return nil
                            }
                        }
                        assert(false,"Why did I reach this line ?")
                    }
                    else
                    {
                        if key == keys.last {
                            return child.value
                        } else {
                            mirror = Mirror(reflecting: child.value)
                            break
                        }
                    }
                }
            }
        }
        return nil
    }

    /// Returns the value for the property identified by a given key.
    subscript (KVC_key key: String) -> Any? {
        get {
            return self.KVC_valueForKeyPath(key)
        }
    }
}

protocol OptionalProtocol {
    func isSome() -> Bool
    func unwrap() -> Any
}

extension Optional : OptionalProtocol {
    func isSome() -> Bool {
        switch self {
        case .None: return false
        case .Some: return true
        }
    }

    func unwrap() -> Any {
        switch self {
        // If a nil is unwrapped it will crash!
        case .None: preconditionFailure("nill unwrap")
        case .Some(let unwrapped): return unwrapped
        }
    }
}


