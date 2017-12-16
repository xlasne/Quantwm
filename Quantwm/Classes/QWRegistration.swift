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
    case schedulingPriority
    case readPathSet
    case writtenPathSet
  }

  let selector: Selector
  let readPathSet: Set<QWPath>
  let name: String
  let writtenPathSet: Set<QWPath>
  let schedulingPriority: Int?
  let maximumAllowedRegistrationWithSameTypeSelector: Int?

  public init(selector: Selector,
              readMap: QWMap,
              name: String,
              writtenMap: QWMap = QWMap(pathArray : []),
              schedulingPriority: Int? = nil,
              maximumAllowedRegistrationWithSameTypeSelector: Int? = nil)
  {
    for path in readMap.qwPathSet {
      if path.access == .writePath {
        assert(false, "Error: Registration \(name) contains a write readPath : \(path)")
      }
    }

    for path in writtenMap.qwPathSet {
      if path.access == .readPath {
        assert(false, "Error: Registration \(name) contains a read in writePath : \(path)")
      }
    }

    self.selector = selector
    self.readPathSet = readMap.qwPathSet
    self.name = name
    self.writtenPathSet = writtenMap.qwPathSet
    self.maximumAllowedRegistrationWithSameTypeSelector = maximumAllowedRegistrationWithSameTypeSelector
    self.schedulingPriority = schedulingPriority


    super.init()
  }

  var writtenPropertySet: Set<QWProperty> {
    return Set(self.writtenPathSet.flatMap{ $0.chain.last })
  }

}
