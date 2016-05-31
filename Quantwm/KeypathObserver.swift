//
//  KeypathObserver.swift
//  QUANTWM
//
//  Created by Xavier Lasne on 29/04/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import Foundation

class KeypathObserver
{
    let keypathDesc: KeypathDescription
    var nodeChain: NodeObserver?
    var updatedNodeChain: NodeObserver?
    var updateCounter: Int = 0

    var keypathBase: String {
        return keypathDesc.rootPath
    }
    var keypathExtension: String? {
        return keypathDesc.extensionPath
    }

    init(root: PropertyDescription, chain: [PropertyDescription])
    {
        let keypathDesc = KeypathDescription(root: root, chain: chain)
        self.keypathDesc = keypathDesc
    }

    init(keypathDesc: KeypathDescription)
    {
        self.keypathDesc = keypathDesc
    }

    func readAndCompareChain(rootNode rootNode: RootNode)
    {
        guard let rootChangeCounter = rootNode.changeCounter,
            let rootObject = rootNode.rootObject else {
                // No Root Node. Clear chain and return
                // If root node was previous present, then there is a change
                if let _ = self.nodeChain {
                    self.nodeChain = nil
                    self.updateCounter += 1
                    print("KeypathObserver: \(keypath) dirty. Rootnode has changed to nil")
                } else {
                    print("KeypathObserver: \(keypath) clean. No Rootnode")
                }
                return
        }
        
        // The root node is not nil.
        // Let's read  and compare the chains
        let updatedNodeChain = self.readChain(keypathDesc, fromRootChangeCounter: rootChangeCounter, rootObject: rootObject)

        // If self.updatedNodeChain is not nil, we are resuming from a suspendRefresh, and must check additional changes, else this is a start refresh
        let previousChain = self.updatedNodeChain ?? self.nodeChain
        let comparison = updatedNodeChain.compareWithPreviousChain(previousChain)
        self.updatedNodeChain = updatedNodeChain
        if comparison.isDirty {
            self.updateCounter += (comparison.isDirty ? 1 : 0)
            print("KeypathObserver: \(keypath) : \(comparison.description) counter updated to \(updateCounter)")
        } else {
            print("KeypathObserver: \(keypath) : \(comparison.description)")
        }

    }

    func readChain(keypathDesc: KeypathDescription, fromRootChangeCounter rootChangeCounter: ChangeCounter, rootObject: MonitoredNode) -> NodeObserver
    {
        if let firstProp = keypathDesc.chain.first
        {
            let nodeObserver = NodeObserver(node: rootChangeCounter, propertyDesc: firstProp)
            nodeObserver.readChain(keypathDesc.chain, fromParent: GenericNode.MonitoredNodeType(rootObject))
            return nodeObserver
        } else {
            let nodeObserver = NodeObserver(node: rootChangeCounter, propertyDesc: keypathDesc.root)
            return nodeObserver
        }
    }

    func commitUpdate() {
        self.nodeChain = self.updatedNodeChain
        self.updatedNodeChain = nil
    }


    var keypath: String {
        return keypathDesc.keypath
    }
    
    var composedKeypath: String {
        if let ext = keypathExtension {
            return "\(keypathBase):\(ext)"
        } else {
            return keypathBase
        }
    }

    var propertyDescriptionSet: Set<String> {
        var result = Set(arrayLiteral: keypathDesc.root.description)
        result.unionInPlace(keypathDesc.chain.map({$0.description}))
        return result
    }

    // This function is only providing correct result just after a readChain method
    func collectNodeSet() -> Set<RW_Action>
    {
        var nodeSet: Set<RW_Action> = []
        if let rootChangeCounter = self.updatedNodeChain?.changeCounter {
            let rootAction = RW_Action(node: rootChangeCounter, property: keypathDesc.root)
            nodeSet.insert(rootAction)
        }
        self.updatedNodeChain?.collectNodeSet(&nodeSet)
        return nodeSet
    }
}
