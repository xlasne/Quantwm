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
        case Loading
        case Update
        case Refresh
    }
    let rw : RW
    weak var owner: NSObject?

    var isUpdate: Bool {
        return self.rw == RW.Update
    }

    var isLoading: Bool {
        return self.rw == RW.Loading
    }

    var isRefresh: Bool {
        return self.rw == RW.Refresh
    }

    init(rw: RW, owner:NSObject?) {
        self.rw = rw
        self.owner = owner
    }
    init(LoadingWithOwner owner:NSObject?) {
        self.rw = RW.Loading
        self.owner = owner
    }

    init(UpdateWithOwner owner:NSObject?) {
        self.rw = RW.Update
        self.owner = owner
    }

    init(refreshOwner:NSObject?) {
        self.rw = RW.Refresh
        self.owner = refreshOwner
    }

    var debugDescription: String {
        switch rw {
        case .Loading:
            return "Loading - \(owner)"
        case .Update:
            return "Update - \(owner)"
        case .Refresh:
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

    func pushContext(rwContext: RWContext) -> RWContext
    {
        switch rwContext.rw {
        case .Loading:
            break
        case .Refresh:
            assert(rwContextStack.isEmpty,"Error: Refresh context can only be pushed on an empty stack")
        case .Update:
            assert(!isRootRefresh,"Error: Update context can not be pushed on Refresh Root Stack")
            assert(!isRootLoading,"Error: Update context can not be pushed on Loading Root Stack")
        }
        rwContextStack.append(rwContext)
        return rwContext
    }

    func popContext(rwContext: RWContext) 
    {
        if let topContext = rwContextStack.last
        {
            if topContext == rwContext {
                rwContextStack.popLast()
            } else {
                assert(false,"Error: DataUsage trying to pop context \(rwContext) which is not matching top context \(rwContextStack.last)")
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
        return "Level(\(readLevel))[\(desc.joinWithSeparator("]["))]"
    }
}
