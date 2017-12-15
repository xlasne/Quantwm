//
//  QWNode.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 10/05/16.
//  Copyright © 2016 XL Software Solutions. => MIT License
//
import Foundation

// The root node shall be an object, in order to keep a weak pointer on it.
public protocol QWRoot: class, QWNode
{
  func generateQWPathTrace(qwPath: QWPath) -> QWPathTraceProtocol
}

public extension QWRoot {
  func generateQWPathTrace(qwPath: QWPath) -> QWPathTraceProtocol
  {
    return QWPathTrace(rootObject: self, qwPath: qwPath)
  }
}

// Implementation via getter method provides the flexibility
// to have a customized way of acessing the monitored node.
public protocol QWNode
{
  func getQWCounter() -> QWCounter
  func getPropertyArray() -> [QWProperty]
}

public protocol QWModelProperty {
    static func getPropertyArray() -> [QWProperty]
}




