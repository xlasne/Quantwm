//
// SwiftKVC - Defines a mechanism by which you can access
// the properties of an object indirectly by name (or key),
// rather than directly through invocation of an accessor method or as instance variables.
//
//
//  Updated by Xavier on 23/04/16.
//  From github : leemorgan/SwiftKVC
//

//import Foundation
//
//typealias ParentAndNode = (parent: SwiftKVC, node: ChangeCounter)
//
//
//public protocol SwiftKVC
//{
//  func KVC_valueExistForKey(_ key : String) -> (exist:Bool, isOptional: Bool?, isSome: Bool)
//  func KVC_valueForKey(_ key : String) -> Any?
//  func KVC_valueForKeyPath(_ keyPath : String) -> Any?
//  subscript (KVC_key key: String) -> Any? { get }
//}
//
//public extension SwiftKVC {
//
//  public func KVC_valueExistForKey(_ key : String) -> (exist:Bool, isOptional: Bool?, isSome: Bool) {
//    let mirror = Mirror(reflecting: self)
//    for myChild in mirror.children {
//      if (myChild.label == key) || (myChild.label == key + ".storage") {
//        if myChild.value is OptionalProtocol
//        {
//          if let optChild = myChild.value as? OptionalProtocol {
//            return (exist:true, isOptional: true, isSome: optChild.isSome())
//          }
//        }
//        else
//        {
//          return (exist:true, isOptional: false, isSome: true)
//        }
//      }
//    }
//    return (exist:false, isOptional: nil, isSome: false)
//  }
//
//  /// Returns the value for the property identified by a given key.
//  public func KVC_valueForKey(_ key : String) -> Any? {
//
//    let mirror = Mirror(reflecting: self)
//    for child in mirror.children {
//      if (child.label == key) || (child.label == key + ".storage") {
//        return child.value
//      }
//    }
//    return nil
//  }
//
//  /// Returns the value for the derived property identified by a given key path.
//  public func KVC_valueForKeyPath(_ keyPath : String) -> Any? {
//    let keys = keyPath.components(separatedBy: ".")
//    var mirror = Mirror(reflecting: self)
//    for key in keys {
//      for child in mirror.children {
//        if (child.label == key) ||
//          (child.label == key + ".storage")  // Case of Lazy initialization
//        {
//          if child.value is OptionalProtocol
//          {
//            if let optChild = child.value as? OptionalProtocol {
//              if optChild.isSome()
//              {
//                let unwrapped = optChild.unwrap()
//                if key == keys.last {
//                  return unwrapped
//                } else {
//                  mirror = Mirror(reflecting: unwrapped)
//                  break
//                }
//              } else {
//                return nil
//              }
//            }
//            assert(false,"I shall not reach this line")
//          }
//          else
//          {
//            if key == keys.last {
//              return child.value
//            } else {
//              mirror = Mirror(reflecting: child.value)
//              break
//            }
//          }
//        }
//      }
//    }
//    return nil
//  }
//
//  /// Returns the value for the property identified by a given key.
//  public subscript (KVC_key key: String) -> Any? {
//    get {
//      return self.KVC_valueForKeyPath(key)
//    }
//  }
//}
//
//protocol OptionalProtocol {
//  func isSome() -> Bool
//  func unwrap() -> Any
//}
//
//extension Optional : OptionalProtocol {
//  func isSome() -> Bool {
//    switch self {
//    case .none: return false
//    case .some: return true
//    }
//  }
//
//  func unwrap() -> Any {
//    switch self {
//    // If a nil is unwrapped it will crash!
//    case .none: preconditionFailure("nill unwrap")
//    case .some(let unwrapped): return unwrapped
//    }
//  }
//}
//
//

