//
//  QWMonitoredNode.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 10/05/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//
import Foundation

public protocol QWMonitoredRoot: class, QWMonitoredNode  // The root node shall be an object, in order to keep a weak pointer on it.
{
  func generateKeypathSignature(keypathDesc: KeypathDescription) -> KeypathSignature
}

public extension QWMonitoredRoot {
  func generateKeypathSignature(keypathDesc: KeypathDescription) -> KeypathSignature
  {
    return ChainNodeObserver(rootObject: self, keypathDesc: keypathDesc)
  }
}

public protocol QWMonitoredNode
{
  func getNodeChangeCounter() -> QWChangeCounter
}
public extension QWMonitoredNode {
  func qwWrite(property: PropertyDescriptor) {
    self.getNodeChangeCounter().performedWriteOnMainThread(property)
  }
  func qwRead(property: PropertyDescriptor) {
    self.getNodeChangeCounter().performedReadOnMainThread(property)
  }
}




