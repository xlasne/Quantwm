//
//  QWMap.swift
//  Spiky
//
//  Created by Xavier on 30/11/2017.
//  Copyright © 2017 XL Software Solutions. => MIT License
//

import Foundation

public struct QWMap
{
  let qwPathSet : Set<QWPath>

  public init(root: QWRootProperty, chain: [QWProperty], andAllChilds: Bool = false)
  {
    let qwPath = QWPath(root: root, chain: chain, andAllChilds: andAllChilds)
    qwPathSet = [qwPath]
  }

  public init(path : QWPath) {
    qwPathSet = [path]
  }

  public init(pathArray : [QWPath])
  {
    qwPathSet = Set(pathArray)
  }

  public init(mapArray : [QWMap])
  {
    var pathSet: Set<QWPath> = []
    mapArray.forEach() { pathSet = pathSet.union( $0.qwPathSet ) }
    qwPathSet = pathSet
  }

  func appending(qwPath: QWPath) -> QWMap
  {
    return QWMap(pathArray: Array(qwPathSet) + [qwPath])
  }

  public func appending(qwMap: QWMap) -> QWMap
  {
    return QWMap(pathArray: Array(qwPathSet) + Array(qwMap.qwPathSet))
  }

}

public func +(lhs: QWMap, rhs: QWMap) -> QWMap
{
  return lhs.appending(qwMap: rhs)
}
