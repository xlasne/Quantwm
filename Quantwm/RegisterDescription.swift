//
//  RegisterDescription.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 19/05/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import Foundation

public class RegisterDescription
{
  let selector: Selector
  let keypathDescriptionSet: Set<KeypathDescription>
  let name: String?
  let writtenPropertySet: Set<PropertyDescription>
  let maximumAllowedRegistrationWithSameTypeSelector: Int?
  let configurationPriority: Int?

  public init(selector: Selector,
              keypathSet: KeypathSet,
              name: String?,
              maximumAllowedRegistrationWithSameTypeSelector: Int? = nil,
              configurationPriority: Int? = nil)
  {
    self.selector = selector
    self.keypathDescriptionSet = keypathSet.readKeypathSet
    self.name = name
    self.writtenPropertySet = keypathSet.writtenPropertySet
    self.maximumAllowedRegistrationWithSameTypeSelector = maximumAllowedRegistrationWithSameTypeSelector
    self.configurationPriority = configurationPriority
  }

  public init(selector: Selector,
              keypathDescriptionSet: Set<KeypathDescription>,
              name: String?,
              writtenPropertySet: Set<PropertyDescription> = [],
              maximumAllowedRegistrationWithSameTypeSelector: Int? = nil,
              configurationPriority: Int? = nil)
  {
    self.selector = selector
    self.keypathDescriptionSet = keypathDescriptionSet
    self.name = name
    self.writtenPropertySet = writtenPropertySet
    self.maximumAllowedRegistrationWithSameTypeSelector = maximumAllowedRegistrationWithSameTypeSelector
    self.configurationPriority = configurationPriority
  }
}