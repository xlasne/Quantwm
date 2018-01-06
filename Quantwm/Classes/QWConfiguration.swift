//
//  QWConfiguration.swift
//  Spiky
//
//  Created by Xavier on 31/12/2017.
//  Copyright © 2017 XL Software Solutions. All rights reserved.
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


  public static var QUANTWM_DEBUG = true

  public static var ReadNonRegisteredProperty: Policy = .isAssert
  public static var WriteNonRegisteredProperty: Policy = .isAssert
  public static var CollectPropertyUsage: Policy = .isAssert

  public static var CheckQuantwmStack: Policy = .isAssert
  public static var CheckPropertyConsistency: Policy = .isAssert




}
