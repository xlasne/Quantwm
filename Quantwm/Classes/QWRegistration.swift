//
//  QWRegistration.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 19/05/16.
//  Copyright © 2016 XL Software Solutions. => MIT License
//

import Foundation

//TODO: move to struct Equatable / Hashable
public class QWRegistration: NSObject, Encodable
{

  // Codable for logging purpose only
  enum CodingKeys: String, CodingKey {
    case name
    case configurationPriority
    case qwPathSet
    case writtenPropertySet
  }


  let selector: Selector
  let qwPathSet: Set<QWPath>
  let name: String
  let writtenPropertySet: Set<QWProperty>
  let maximumAllowedRegistrationWithSameTypeSelector: Int?
  let configurationPriority: Int?
  
  public init(selector: Selector,
              qwMap: QWMap,
              name: String,
              writtenPropertyArray: [QWProperty] = [],
              configurationPriority: Int? = nil,
              maximumAllowedRegistrationWithSameTypeSelector: Int? = nil)
  {
    self.selector = selector
    self.qwPathSet = qwMap.qwPathSet
    self.name = name
    self.writtenPropertySet = Set(writtenPropertyArray)
    self.maximumAllowedRegistrationWithSameTypeSelector = maximumAllowedRegistrationWithSameTypeSelector
    self.configurationPriority = configurationPriority

    super.init()
  }

}
