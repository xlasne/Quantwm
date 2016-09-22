//
//  CodingConverter.swift
//  Spiky
//
//  Created by Xavier Lasne on 26/04/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import Foundation

public enum CodingConverterResult<T> {
  case success(T)
  case noTypeMatch
  case keyNotFound
}

open class CodingConverter<T> {


  static open func encode(_ aCoder: NSCoder, value: T, propertyDescription: PropertyDescription)
  {
    let codingKey = propertyDescription.propKey
    assert(T.self == propertyDescription.destType,"Error: type do not match")
    let result = CodingConverter<T>.encodeAsNSNumber(aCoder, value: value, codingKey: codingKey)
    switch result {
    case .keyNotFound:
      assert(false,"MonitoredValue: Programming Error - encode never returns KeyNotFound")
      break
    case .noTypeMatch:
      if let value = value as? AnyObject {
        aCoder.encode(value, forKey: codingKey)
      } else {
        assert(false, "MonitoredValue: encodeWithCoder: Failed to encode value")
      }
    case .success:
      break
    }
  }

  static open func decode(_ aDecoder: NSCoder, propertyDescription: PropertyDescription) -> T?
  {
    let codingKey = propertyDescription.propKey
    assert(T.self == propertyDescription.destType,"Error: type do not match")
    let result = CodingConverter<T>.decodeAsNSNumber(aDecoder, codingKey: codingKey)
    switch result {
    case .keyNotFound:
      return nil
    case .noTypeMatch:
      if let decodedValue = aDecoder.decodeObject(forKey: codingKey) as? T {
        return decodedValue
      } else {
        return nil
      }
    case .success(let decodedValue):
      return decodedValue
    }
  }


  static open func encodeAsNSNumber(_ aCoder: NSCoder, value: T, codingKey: String) -> CodingConverterResult<T>
  {
    var success = false
    if T.self == Bool.self {
      if let value = value as? Bool {
        let numValue = NSNumber(value: value as Bool)
        aCoder.encode(numValue, forKey: codingKey)
        success = true
      }
    }
    if T.self == Int.self {
      if let value = value as? Int {
        let numValue = NSNumber(value: value as Int)
        aCoder.encode(numValue, forKey: codingKey)
        success = true
      }
    }
    if T.self == UInt.self {
      if let value = value as? UInt {
        let numValue = NSNumber(value: value as UInt)
        aCoder.encode(numValue, forKey: codingKey)
        success = true
      }
    }
    if T.self == Double.self {
      if let value = value as? Double {
        let doubleValue = NSNumber(value: value as Double)
        aCoder.encode(doubleValue, forKey: codingKey)
        success = true
      }
    }
    if T.self == Float.self {
      if let value = value as? Float {
        let floatValue = NSNumber(value: value as Float)
        aCoder.encode(floatValue, forKey: codingKey)
        success = true
      }
    }
    if T.self == CGFloat.self {
      if let value = value as? Float {
        let floatValue = NSNumber(value: Float(value) as Float)
        aCoder.encode(floatValue, forKey: codingKey)
        success = true
      }
    }
    if T.self == Int8.self {
      if let value = value as? Int8 {
        let numValue = NSNumber(value: value as Int8)
        aCoder.encode(numValue, forKey: codingKey)
        success = true
      }
    }
    if T.self == UInt8.self {
      if let value = value as? UInt8 {
        let numValue = NSNumber(value: value as UInt8)
        aCoder.encode(numValue, forKey: codingKey)
        success = true
      }
    }
    if T.self == Int16.self {
      if let value = value as? Int16 {
        let numValue = NSNumber(value: value as Int16)
        aCoder.encode(numValue, forKey: codingKey)
        success = true
      }
    }
    if T.self == UInt16.self {
      if let value = value as? UInt16 {
        let numValue = NSNumber(value: value as UInt16)
        aCoder.encode(numValue, forKey: codingKey)
        success = true
      }
    }
    if T.self == Int32.self {
      if let value = value as? Int32 {
        let numValue = NSNumber(value: value as Int32)
        aCoder.encode(numValue, forKey: codingKey)
        success = true
      }
    }
    if T.self == UInt32.self {
      if let value = value as? UInt32 {
        let numValue = NSNumber(value: value as UInt32)
        aCoder.encode(numValue, forKey: codingKey)
        success = true
      }
    }
    if T.self == Int64.self {
      if let value = value as? Int64 {
        let numValue = NSNumber(value: value as Int64)
        aCoder.encode(numValue, forKey: codingKey)
        success = true
      }
    }
    if T.self == UInt64.self {
      if let value = value as? UInt64 {
        let numValue = NSNumber(value: value as UInt64)
        aCoder.encode(numValue, forKey: codingKey)
        success = true
      }
    }
    if success {
      return CodingConverterResult<T>.success(value)
    } else {
      return CodingConverterResult<T>.noTypeMatch
    }
  }

  static open func decodeAsNSNumber(_ aDecoder: NSCoder, codingKey: String) -> CodingConverterResult<T>
  {
    if T.self == Bool.self {
      if let val = aDecoder.decodeObject(forKey: codingKey) as? NSNumber,
        let decodedValue = val.boolValue as? T {
        return CodingConverterResult.success(decodedValue)
      } else {
        return CodingConverterResult.keyNotFound
      }
    }
    if T.self == Int.self {
      if let val = aDecoder.decodeObject(forKey: codingKey) as? NSNumber,
        let decodedValue = val.intValue as? T {
        return CodingConverterResult.success(decodedValue)
      } else {
        return CodingConverterResult.keyNotFound
      }
    }
    if T.self == UInt.self {
      if let val = aDecoder.decodeObject(forKey: codingKey) as? NSNumber,
        let decodedValue = val.uintValue as? T {
        return CodingConverterResult.success(decodedValue)
      } else {
        return CodingConverterResult.keyNotFound
      }
    }
    if T.self == Double.self {
      if let val = aDecoder.decodeObject(forKey: codingKey) as? NSNumber,
        let decodedValue = val.doubleValue as? T {
        return CodingConverterResult.success(decodedValue)
      } else {
        return CodingConverterResult.keyNotFound
      }
    }
    if T.self == CGFloat.self {
      if let val = aDecoder.decodeObject(forKey: codingKey) as? NSNumber {
        let floatValue = CGFloat(val.floatValue)
        if let decodedValue = floatValue as? T {
          return CodingConverterResult.success(decodedValue)
        } else {
          return CodingConverterResult.keyNotFound
        }
      }
    }
    if T.self == Float.self {
      if let val = aDecoder.decodeObject(forKey: codingKey) as? NSNumber,
        let decodedValue = val.floatValue as? T {
        return CodingConverterResult.success(decodedValue)
      } else {
        return CodingConverterResult.keyNotFound
      }
    }
    if T.self == Int8.self {
      if let val = aDecoder.decodeObject(forKey: codingKey) as? NSNumber,
        let decodedValue = val.int8Value as? T {
        return CodingConverterResult.success(decodedValue)
      } else {
        return CodingConverterResult.keyNotFound
      }
    }
    if T.self == UInt8.self {
      if let val = aDecoder.decodeObject(forKey: codingKey) as? NSNumber,
        let decodedValue = val.uint8Value as? T {
        return CodingConverterResult.success(decodedValue)
      } else {
        return CodingConverterResult.keyNotFound
      }
    }
    if T.self == Int16.self {
      if let val = aDecoder.decodeObject(forKey: codingKey) as? NSNumber,
        let decodedValue = val.int16Value as? T {
        return CodingConverterResult.success(decodedValue)
      } else {
        return CodingConverterResult.keyNotFound
      }
    }
    if T.self == UInt16.self {
      if let val = aDecoder.decodeObject(forKey: codingKey) as? NSNumber,
        let decodedValue = val.uint16Value as? T {
        return CodingConverterResult.success(decodedValue)
      } else {
        return CodingConverterResult.keyNotFound
      }
    }
    if T.self == Int32.self {
      if let val = aDecoder.decodeObject(forKey: codingKey) as? NSNumber,
        let decodedValue = val.int32Value as? T {
        return CodingConverterResult.success(decodedValue)
      } else {
        return CodingConverterResult.keyNotFound
      }
    }
    if T.self == UInt32.self {
      if let val = aDecoder.decodeObject(forKey: codingKey) as? NSNumber,
        let decodedValue = val.uint32Value as? T {
        return CodingConverterResult.success(decodedValue)
      } else {
        return CodingConverterResult.keyNotFound
      }
    }
    if T.self == Int64.self {
      if let val = aDecoder.decodeObject(forKey: codingKey) as? NSNumber,
        let decodedValue = val.int64Value as? T {
        return CodingConverterResult.success(decodedValue)
      } else {
        return CodingConverterResult.keyNotFound
      }
    }
    if T.self == UInt64.self {
      if let val = aDecoder.decodeObject(forKey: codingKey) as? NSNumber,
        let decodedValue = val.uint64Value as? T {
        return CodingConverterResult.success(decodedValue)
      } else {
        return CodingConverterResult.keyNotFound
      }
    }
    return CodingConverterResult.noTypeMatch
  }
}
