//
//  QWConfiguration.swift
//  Spiky
//
//  Created by Xavier Lasne on 31/12/2017.
//  MIT License
//

import Foundation


public class QWConfiguration {

  public enum Policy {
    case isIgnore
    case isPrint
    case isAssert

    var notIgnore: Bool {
      return self != .isIgnore
    }

    func process(errorStr: String) {
      switch QWConfiguration.ReadNonRegisteredProperty {
      case .isAssert:
        assert(false,errorStr)
      case .isPrint:
        Swift.print(errorStr)
      case .isIgnore:
        break
      }
    }
  }


  public static var QUANTWM_DEBUG = false

  public static var ReadNonRegisteredProperty: Policy = .isAssert
  public static var WriteNonRegisteredProperty: Policy = .isAssert
  public static var CollectPropertyUsage: Policy = .isAssert

  public static var CheckQuantwmStack: Policy = .isAssert
  public static var CheckPropertyConsistency: Policy = .isAssert

  public static var StorageConsistency: Policy = .isAssert

}
