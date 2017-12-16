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
    case readPathSet
    case writtenPathSet
  }

  let selector: Selector
  let readPathSet: Set<QWPath>
  let name: String
  let writtenPathSet: Set<QWPath>
  let configurationPriority: Int?
  let maximumAllowedRegistrationWithSameTypeSelector: Int?

  public init(selector: Selector,
              readMap: QWMap,
              name: String,
              writtenMap: QWMap = QWMap(pathArray : []),
              configurationPriority: Int? = nil,
              maximumAllowedRegistrationWithSameTypeSelector: Int? = nil)
  {
    self.selector = selector
    self.readPathSet = readMap.qwPathSet
    self.name = name
    self.writtenPathSet = writtenMap.qwPathSet
    self.maximumAllowedRegistrationWithSameTypeSelector = maximumAllowedRegistrationWithSameTypeSelector
    self.configurationPriority = configurationPriority

    super.init()
  }

  var writtenPropertySet: Set<QWProperty> {
    return Set(self.writtenPathSet.flatMap{ $0.chain.last })
  }

}
