//
//  DataContext.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 23/04/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import Foundation

//MARK: - RWContext
struct RWContext: Equatable, CustomDebugStringConvertible
{
  enum RW: Int
  {
    case loading
    case update
    case refresh
  }
  let rw : RW
  weak var owner: NSObject?

  var isUpdate: Bool {
    return self.rw == RW.update
  }

  var isLoading: Bool {
    return self.rw == RW.loading
  }

  var isRefresh: Bool {
    return self.rw == RW.refresh
  }

  init(rw: RW, owner:NSObject?) {
    self.rw = rw
    self.owner = owner
  }
  init(LoadingWithOwner owner:NSObject?) {
    self.rw = RW.loading
    self.owner = owner
  }

  init(UpdateWithOwner owner:NSObject?) {
    self.rw = RW.update
    self.owner = owner
  }

  init(refreshOwner:NSObject?) {
    self.rw = RW.refresh
    self.owner = refreshOwner
  }

  var debugDescription: String {
    switch rw {
    case .loading:
        return "Loading - \(String(describing: owner))"
    case .update:
        return "Update - \(String(describing: owner))"
    case .refresh:
      return "Refresh"
    }
  }
}

func ==(lhs: RWContext, rhs: RWContext) -> Bool {
  let areEqual = lhs.rw.rawValue == rhs.rw.rawValue &&
    lhs.owner === rhs.owner
  return areEqual
}

//MARK: - DataContext
class DataContext {

  var rwContextStack: [RWContext] = []
  var readLevel: Int = -1

  var rootContext : RWContext? {
    return rwContextStack.first
  }

  var isRootRefresh: Bool {
    return rootContext?.isRefresh ?? false
  }

  var isRootUpdate: Bool {
    return rootContext?.isUpdate ?? false
  }

  var isRootLoading: Bool {
    return rootContext?.isLoading ?? false
  }

  // Rule 1: Push/Pop context should be recursive
  // Rule 2: It is forbidden to push Update context while on Refresh or Loading root stack
  // Rule 3: Refresh context shall be root stack
  var isUpdateAllowed: Bool {
    return rwContextStack.isEmpty || isRootUpdate
  }

  var isRefreshAllowed: Bool {
    return rwContextStack.isEmpty
  }

  func pushContext(_ rwContext: RWContext)
  {
    switch rwContext.rw {
    case .loading:
      break
    case .refresh:
      assert(rwContextStack.isEmpty,"Error: Refresh context can only be pushed on an empty stack")
    case .update:
      assert(!isRootRefresh,"Error: Update context can not be pushed on Refresh Root Stack")
      assert(!isRootLoading,"Error: Update context can not be pushed on Loading Root Stack")
    }
    rwContextStack.append(rwContext)
  }

  func popContext(_ rwContext: RWContext)
  {
    if let topContext = rwContextStack.last
    {
      if topContext == rwContext {
        let _ = rwContextStack.popLast()
      } else {
        assert(false,"Error: DataUsage trying to pop context \(rwContext) which is not matching top context \(String(describing: rwContextStack.last))")
      }
    } else {
      assert(false,"Error: DataUsage trying to pop context \(rwContext) on an empty stack")
    }
  }

  var isStackEmpty: Bool {
    return rwContextStack.isEmpty
  }

  var stackDescription: String {
    let desc = self.rwContextStack.map({$0.debugDescription})
    return "Level(\(readLevel))[\(desc.joined(separator: "]["))]"
  }
}
