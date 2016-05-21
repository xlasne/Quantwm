//
//  DataContext.swift
//  QUANTWM
//
//  Created by Xavier on 23/04/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import Foundation

//MARK: - RWContext
struct RWContext: Equatable, CustomDebugStringConvertible
{
    enum RW: Int
    {
        case ReadOnly
        case ReadWrite
        case Refresh
    }
    let rw : RW
    weak var owner: NSObject?

    var isRW: Bool {
        return self.rw == RW.ReadWrite
    }

    var isRO: Bool {
        return self.rw == RW.ReadOnly
    }

    var isRefresh: Bool {
        return self.rw == RW.Refresh
    }

    init(rw: RW, owner:NSObject?) {
        self.rw = rw
        self.owner = owner
    }
    init(ReadOnlyWithOwner owner:NSObject?) {
        self.rw = RW.ReadOnly
        self.owner = owner
    }

    init(ReadWriteWithOwner owner:NSObject?) {
        self.rw = RW.ReadWrite
        self.owner = owner
    }

    init(refreshOwner:NSObject?) {
        self.rw = RW.Refresh
        self.owner = refreshOwner
    }

    var debugDescription: String {
        switch rw {
        case .ReadOnly:
            return "RO - \(owner)"
        case .ReadWrite:
            return "RW - \(owner)"
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
    var refreshUIHasBeenCalledOnceWithTheRootReadOnlyTransaction = false
    var readLevel: Int = -1

    var rootContext : RWContext? {
        return rwContextStack.first
    }

    var isRootRefresh: Bool {
        return rootContext?.isRefresh ?? false
    }

    var isRootRW: Bool {
        return rootContext?.isRW ?? false
    }

    var isRootRO: Bool {
        return rootContext?.isRO ?? false
    }

    // Rule 1: Push/Pop context should be recursive
    // Rule 2: It is forbidden to push ReadWrite context while on Refresh or RO root stack
    // Rule 3: Refresh context shall be root stack
    var isReadWriteAllowed: Bool {
        return rwContextStack.isEmpty || isRootRW
    }

    var isRefreshAllowed: Bool {
        return rwContextStack.isEmpty
    }

    func pushContext(rwContext: RWContext) -> RWContext
    {
        switch rwContext.rw {
        case .ReadOnly:
            break
        case .Refresh:
            assert(rwContextStack.isEmpty,"Error: Refresh context can only be pushed on an empty stack")
        case .ReadWrite:
            assert(!isRootRefresh,"Error: ReadWrite context can not be pushed on Refresh Root Stack")
            assert(!isRootRO,"Error: ReadWrite context can not be pushed on Read Only Root Stack")
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
