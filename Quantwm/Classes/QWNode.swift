//
//  QWNode.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 10/05/16.
//  Copyright  MIT License
//
import Foundation

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



// The root node shall be an object, in order to keep a weak pointer on it.

/// QWRoot is the model Root.
/// QWRoot shall register itself via QWMediator.registerRoot()
/// QWRoot is the root of all the QWPath registered to the mediator
/// QWRoot is the root of the QWModel generated via Sourcery Sourcery_QuantwmModel.stencil
/// QWRoot shall have a root property like:
/// //sourcery: root
/// static let dataModelK = QWRootProperty(rootType: DataModel.self, rootId: "dataModel")
/// Check Quantwm.swift for Mediator customization for referencing the DataModel
public protocol QWRoot: class, QWNode
{
  func generateQWPathTrace(qwPath: QWPath) -> QWPathTraceSnapshot
}

public extension QWRoot {
  /// Generate
  func generateQWPathTrace(qwPath: QWPath) -> QWPathTraceSnapshot
  {
    return QWPathTrace(rootObject: self, qwPath: qwPath)
  }
}





