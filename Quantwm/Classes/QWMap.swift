//
//  QWMap.swift
//  Spiky
//
//  Created by Xavier Lasne on 30/11/2017.
//  Copyright  MIT License
//

import Foundation

public struct QWMap
{
  let qwPathSet : Set<QWPath>

  public init(map : QWMap) {
    qwPathSet = map.qwPathSet
  }

  public init(root: QWRootProperty, chain: [QWProperty], andAllChilds: Bool = false)
  {
    let qwPath = QWPath(root: root, chain: chain, andAllChilds: andAllChilds)
    qwPathSet = [qwPath]
  }

  public init(path: QWPath) {
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
  let map = QWMap(pathArray: Array(lhs.qwPathSet))
  return map.appending(qwMap: rhs)
}
