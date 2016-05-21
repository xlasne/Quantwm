//
//  Scene2ViewModel.swift
//  MVVM
//
//  Created by Xavier on 08/04/16.
//  Copyright © 2016 XL Software Solutions
//

import Foundation
import AppKit

class Scene2ViewModel: GenericViewModel
{
    // Generic View Model
    init(dataModel : DataModel, viewController: Scene2ViewController)
    {
        super.init(dataModel: dataModel, owner: viewController)
    }

    // MARK: - Input Processing
    func setValue2(numberStr: String, focus: NSObject?)
    {
        let formatter = NSNumberFormatter()
        if let val = formatter.numberFromString(numberStr)?.integerValue
        {
            writeActionAndRefresh(owner: owner) {
                if val != self.dataModel.number2
                {
                    self.dataModel.number2 = val
                }
                self.contextMgr.currentFocus = focus
            }
        } else {
            NSBeep()
        }
    }
    
    func toggleImageColor() {
        writeActionAndRefresh(owner: owner) {
            let color = self.contextMgr.imageColor
            if color == NSColor.whiteColor() {
                print("Switch color white to green")
                self.contextMgr.imageColor = NSColor.greenColor()
            } else {
                print("Switch color green to white")
                self.contextMgr.imageColor = NSColor.whiteColor()
            }
        }
    }

    // MARK: - Get Data Model

    //MARK: getFocus
    static func getFocusKeypath() -> Set<KeypathDescription>
    {
        let keypathDescription = KeypathDescription(root: ContextMgr.contextMgrK, chain: [ContextMgr.currentFocusK])
        return [keypathDescription]
    }

    func getFocus() -> NSObject? {
        return self.contextMgr.observed.currentFocus
    }

    //MARK: getValue2
    static func getValue2Keypaths() -> Set<KeypathDescription>
    {
        let keypathDescription = KeypathDescription(root:DataModel.dataModelK, chain:[DataModel.number2K])
        return [keypathDescription]
    }

    func getValue2() -> String {
        let formatter = NSNumberFormatter()
        let val = self.dataModel.observedSelf.number2
        return  formatter.stringFromNumber(val) ?? "Error"
    }


    //MARK: getSum
    static func getSumKeypaths() -> Set<KeypathDescription>
    {
        let keypathDescription = KeypathDescription(root:DataModel.dataModelK, chain: [DataModel.sumOfNumberK])
        return [keypathDescription]
    }

    func getSum() -> Int?
    {
        let sum = self.dataModel.observedSelf.getSum()
        return sum
    }

    //MARK: getColor
    static func getColorKeypaths() -> Set<KeypathDescription>
    {
        let keypathDescription = KeypathDescription(root:ContextMgr.contextMgrK, chain: [ContextMgr._imageColorK])
        return [keypathDescription]
    }

    func getColor() -> NSColor
    {
        return self.contextMgr.observed.imageColor
    }
}