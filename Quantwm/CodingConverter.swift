//
//  CodingConverter.swift
//  Spiky
//
//  Created by Xavier on 26/04/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import Foundation

public enum CodingConverterResult<T> {
    case Success(T)
    case NoTypeMatch
    case KeyNotFound
}

public class CodingConverter<T> {


    static public func encode(aCoder: NSCoder, value: T, propertyDescription: PropertyDescription)
    {
        let codingKey = propertyDescription.propKey
        assert(T.self == propertyDescription.destType,"Error: type do not match")
        let result = CodingConverter<T>.encodeAsNSNumber(aCoder, value: value, codingKey: codingKey)
        switch result {
        case .KeyNotFound:
            assert(false,"MonitoredValue: Programming Error - encode never returns KeyNotFound")
            break
        case .NoTypeMatch:
            if let value = value as? AnyObject {
                aCoder.encodeObject(value, forKey: codingKey)
            } else {
                assert(false, "MonitoredValue: encodeWithCoder: Failed to encode value")
            }
        case .Success:
            break
        }
    }

    static public func decode(aDecoder: NSCoder, propertyDescription: PropertyDescription) -> T?
    {
        let codingKey = propertyDescription.propKey
        assert(T.self == propertyDescription.destType,"Error: type do not match")
        let result = CodingConverter<T>.decodeAsNSNumber(aDecoder, codingKey: codingKey)
        switch result {
        case .KeyNotFound:
            return nil
        case .NoTypeMatch:
            if let decodedValue = aDecoder.decodeObjectForKey(codingKey) as? T {
                return decodedValue
            } else {
                return nil
            }
        case .Success(let decodedValue):
            return decodedValue
        }
    }


    static public func encodeAsNSNumber(aCoder: NSCoder, value: T, codingKey: String) -> CodingConverterResult<T>
    {
        var success = false
        if T.self == Bool.self {
            if let value = value as? Bool {
                let numValue = NSNumber(bool: value)
                aCoder.encodeObject(numValue, forKey: codingKey)
                success = true
            }
        }
        if T.self == Int.self {
            if let value = value as? Int {
                let numValue = NSNumber(integer: value)
                aCoder.encodeObject(numValue, forKey: codingKey)
                success = true
            }
        }
        if T.self == UInt.self {
            if let value = value as? UInt {
                let numValue = NSNumber(unsignedInteger: value)
                aCoder.encodeObject(numValue, forKey: codingKey)
                success = true
            }
        }
        if T.self == Double.self {
            if let value = value as? Double {
                let doubleValue = NSNumber(double: value)
                aCoder.encodeObject(doubleValue, forKey: codingKey)
                success = true
            }
        }
        if T.self == Float.self {
            if let value = value as? Float {
                let floatValue = NSNumber(float: value)
                aCoder.encodeObject(floatValue, forKey: codingKey)
                success = true
            }
        }
        if T.self == CGFloat.self {
            if let value = value as? Float {
                let floatValue = NSNumber(float: Float(value) )
                aCoder.encodeObject(floatValue, forKey: codingKey)
                success = true
            }
        }
        if T.self == Int8.self {
            if let value = value as? Int8 {
                let numValue = NSNumber(char: value)
                aCoder.encodeObject(numValue, forKey: codingKey)
                success = true
            }
        }
        if T.self == UInt8.self {
            if let value = value as? UInt8 {
                let numValue = NSNumber(unsignedChar: value)
                aCoder.encodeObject(numValue, forKey: codingKey)
                success = true
            }
        }
        if T.self == Int16.self {
            if let value = value as? Int16 {
                let numValue = NSNumber(short: value)
                aCoder.encodeObject(numValue, forKey: codingKey)
                success = true
            }
        }
        if T.self == UInt16.self {
            if let value = value as? UInt16 {
                let numValue = NSNumber(unsignedShort: value)
                aCoder.encodeObject(numValue, forKey: codingKey)
                success = true
            }
        }
        if T.self == Int32.self {
            if let value = value as? Int32 {
                let numValue = NSNumber(int: value)
                aCoder.encodeObject(numValue, forKey: codingKey)
                success = true
            }
        }
        if T.self == UInt32.self {
            if let value = value as? UInt32 {
                let numValue = NSNumber(unsignedInt: value)
                aCoder.encodeObject(numValue, forKey: codingKey)
                success = true
            }
        }
        if T.self == Int64.self {
            if let value = value as? Int64 {
                let numValue = NSNumber(longLong: value)
                aCoder.encodeObject(numValue, forKey: codingKey)
                success = true
            }
        }
        if T.self == UInt64.self {
            if let value = value as? UInt64 {
                let numValue = NSNumber(unsignedLongLong: value)
                aCoder.encodeObject(numValue, forKey: codingKey)
                success = true
            }
        }
        if success {
            return CodingConverterResult<T>.Success(value)
        } else {
            return CodingConverterResult<T>.NoTypeMatch
        }
    }

    static public func decodeAsNSNumber(aDecoder: NSCoder, codingKey: String) -> CodingConverterResult<T>
    {
        if T.self == Bool.self {
            if let val = aDecoder.decodeObjectForKey(codingKey) as? NSNumber,
                let decodedValue = val.boolValue as? T {
                return CodingConverterResult.Success(decodedValue)
            } else {
                return CodingConverterResult.KeyNotFound
            }
        }
        if T.self == Int.self {
            if let val = aDecoder.decodeObjectForKey(codingKey) as? NSNumber,
                let decodedValue = val.integerValue as? T {
                return CodingConverterResult.Success(decodedValue)
            } else {
                return CodingConverterResult.KeyNotFound
            }
        }
        if T.self == UInt.self {
            if let val = aDecoder.decodeObjectForKey(codingKey) as? NSNumber,
                let decodedValue = val.unsignedIntegerValue as? T {
                return CodingConverterResult.Success(decodedValue)
            } else {
                return CodingConverterResult.KeyNotFound
            }
        }
        if T.self == Double.self {
            if let val = aDecoder.decodeObjectForKey(codingKey) as? NSNumber,
                let decodedValue = val.doubleValue as? T {
                return CodingConverterResult.Success(decodedValue)
            } else {
                return CodingConverterResult.KeyNotFound
            }
        }
        if T.self == CGFloat.self {
            if let val = aDecoder.decodeObjectForKey(codingKey) as? NSNumber {
                let floatValue = CGFloat(val.floatValue)
                if let decodedValue = floatValue as? T {
                    return CodingConverterResult.Success(decodedValue)
                } else {
                    return CodingConverterResult.KeyNotFound
                }
            }
        }
        if T.self == Float.self {
            if let val = aDecoder.decodeObjectForKey(codingKey) as? NSNumber,
                let decodedValue = val.floatValue as? T {
                return CodingConverterResult.Success(decodedValue)
            } else {
                return CodingConverterResult.KeyNotFound
            }
        }
        if T.self == Int8.self {
            if let val = aDecoder.decodeObjectForKey(codingKey) as? NSNumber,
                let decodedValue = val.charValue as? T {
                return CodingConverterResult.Success(decodedValue)
            } else {
                return CodingConverterResult.KeyNotFound
            }
        }
        if T.self == UInt8.self {
            if let val = aDecoder.decodeObjectForKey(codingKey) as? NSNumber,
                let decodedValue = val.unsignedCharValue as? T {
                return CodingConverterResult.Success(decodedValue)
            } else {
                return CodingConverterResult.KeyNotFound
            }
        }
        if T.self == Int16.self {
            if let val = aDecoder.decodeObjectForKey(codingKey) as? NSNumber,
            let decodedValue = val.shortValue as? T {
                return CodingConverterResult.Success(decodedValue)
            } else {
                return CodingConverterResult.KeyNotFound
            }
        }
        if T.self == UInt16.self {
            if let val = aDecoder.decodeObjectForKey(codingKey) as? NSNumber,
            let decodedValue = val.unsignedShortValue as? T {
                return CodingConverterResult.Success(decodedValue)
            } else {
                return CodingConverterResult.KeyNotFound
            }
        }
        if T.self == Int32.self {
            if let val = aDecoder.decodeObjectForKey(codingKey) as? NSNumber,
            let decodedValue = val.intValue as? T {
                return CodingConverterResult.Success(decodedValue)
            } else {
                return CodingConverterResult.KeyNotFound
            }
        }
        if T.self == UInt32.self {
            if let val = aDecoder.decodeObjectForKey(codingKey) as? NSNumber,
            let decodedValue = val.unsignedIntValue as? T {
                return CodingConverterResult.Success(decodedValue)
            } else {
                return CodingConverterResult.KeyNotFound
            }
        }
        if T.self == Int64.self {
            if let val = aDecoder.decodeObjectForKey(codingKey) as? NSNumber,
            let decodedValue = val.longLongValue as? T {
                return CodingConverterResult.Success(decodedValue)
            } else {
                return CodingConverterResult.KeyNotFound
            }
        }
        if T.self == UInt64.self {
            if let val = aDecoder.decodeObjectForKey(codingKey) as? NSNumber,
            let decodedValue = val.unsignedLongLongValue as? T {
                return CodingConverterResult.Success(decodedValue)
            } else {
                return CodingConverterResult.KeyNotFound
            }
        }
        return CodingConverterResult.NoTypeMatch
    }
}