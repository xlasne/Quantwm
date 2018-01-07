//
//  QWTransactionStack.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 23/04/16.
//  Copyright  MIT License
//

import Foundation

// Define the current context of Quantwm framework
// - notif: allows reading from the model
// - update: allows read and write from the model
// - refresh: indicates that a refreshUI() is under processing.
//
// These contexts are stacked on a context stack. The first item is the rootContext.
// Based on the rootContext, the stack becomes an update or refresh stack.
//
// - Refresh shall always be pushed on an empty stack.
// - Update can only be pushed on an update stack, and thus forbidden on refresh or reading stack.
//   Calls to refreshUI() while processing an update stack are delayed until the pop of the update.
//

//MARK: - RWContext
class RWContext: CustomDebugStringConvertible
{
  enum RW: Int
  {
    case notif
    case update
    case refresh
  }
  let rw : RW
  var owner: String
  weak var registrationUsage: QWRegistrationUsage? = nil

  var isUpdating: Bool {
    return self.rw == RW.update
  }
  
  var isNotification: Bool {
    return self.rw == RW.notif
  }
  
  var isRefreshing: Bool {
    return self.rw == RW.refresh
  }
  
  init(rw: RW, owner:String) {
    self.rw = rw
    self.owner = owner
  }

  init(notificationOwner owner:String, registrationUsage: QWRegistrationUsage?) {
    self.rw = RW.notif
    self.owner = owner
    self.registrationUsage = registrationUsage
  }
  
  init(updateOwner owner:String) {
    self.rw = RW.update
    self.owner = owner
  }
  
  init(refreshOwner:String) {
    self.rw = RW.refresh
    self.owner = refreshOwner
  }
  
  var debugDescription: String {
    switch rw {
    case .notif:
      return "Loading - \(owner)"
    case .update:
      return "Update - \(owner)"
    case .refresh:
      return "Refresh"
    }
  }
}


struct QWStackReadLevel {
  let currentTag: String
  let readLevel: Int
}

//MARK: - QWTransactionStack
class QWTransactionStack {
  
  var rwContextStack: [RWContext] = []
  var readLevel: Int = -1
  var currentTag: String = ""

  var stackReadLevel: QWStackReadLevel {
    get {
      return QWStackReadLevel(currentTag: currentTag, readLevel: readLevel)
    }
    set  {
      self.readLevel = newValue.readLevel
      self.currentTag = newValue.currentTag
    }
  }


  var rootContext : RWContext? {
    return rwContextStack.first
  }
  
  var isRootRefresh: Bool {
    return rootContext?.isRefreshing ?? false
  }
  
  var isRootUpdate: Bool {
    return rootContext?.isUpdating ?? false
  }

  // Rule 1: Push/Pop context should be recursive
  // Rule 2: It is forbidden to push Update context while on Refresh root stack
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
    case .notif:
      assert(isRootRefresh,"Error: Notification can only be pushed on Refresh Root Stack")
    case .refresh:
      assert(rwContextStack.isEmpty,"Error: Refresh context can only be pushed on an empty stack")
    case .update:
      assert(!isRootRefresh,"Error: Update context can not be pushed on Refresh Root Stack")
    }
    rwContextStack.append(rwContext)
  }
  
  func popContext(_ rwContext: RWContext)
  {
    if let topContext = rwContextStack.last
    {
      if topContext === rwContext {
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
