//
//  DataModel.swift
//  MVVM
//
//  Created by Xavier Lasne on 08/04/16.
//  Copyright © 2016 XL Software Solutions
//

//KEYPOINT 1:
// Manage stored data hierarchy and dependencies
// Unaware of View Controllers
// After external Stored Data update, does not trigger refresh because unaware of the context of these updates
// After progress / background update, triggers UI refresh via Context Mgr (ex: Sum Processor)

import Foundation
import AppKit
import QuantwmOSX

class DataModel : NSObject, MonitoredClass, RepositoryHolder, MonitoredNode
{


    // MARK: Interfaces
    weak var document: DemoDocument!

    let contextMgr: ContextMgr = ContextMgr()
    let repositoryObserver: RepositoryObserver

    func getRepositoryObserver() -> RepositoryObserver
    {
        return repositoryObserver
    }

    static let dataModelK = RootDescriptor(description: "DataModel",
                                           sourceType: DataModel.self)


    func getNodeChangeCounter() -> ChangeCounter {
        return changeCounter
    }
    var changeCounter = ChangeCounter()

    var observedSelf: DataModel {
        return self
    }

    static let number1K = PropertyDescriptor(keypath: \DataModel.number1,
                                             description: "number1")

    fileprivate var _number1: Int = 1
    var number1 : Int {
        get {
            self.changeCounter.performedReadOnMainThread(DataModel.number1K)
            return _number1
        }
        set {
            self.changeCounter.performedWriteOnMainThread(DataModel.number1K)
            _number1 = newValue
            self.document.updateChangeCount(NSDocument.ChangeType.changeDone)
        }
    }

    static let number2K = PropertyDescriptor(keypath: \DataModel.number2,
                                             description: "number2")
    fileprivate var _number2: Int = 2
    var number2 : Int {
        get {
            self.changeCounter.performedReadOnMainThread(DataModel.number2K)
            return _number2
        }
        set {
            self.changeCounter.performedWriteOnMainThread(DataModel.number2K)
            _number2 = newValue
            self.document.updateChangeCount(NSDocument.ChangeType.changeDone)
        }
    }

    // MARK: Computed Content
    static let sumOfNumberK = PropertyDescriptor(keypath: \DataModel.sumOfNumber,
                                                 description: "sumOfNumber",
                                                 dependFromPropertySet: [DataModel.number1K, DataModel.number2K])

    fileprivate var _sumOfNumber: Int = 0
    var sumOfNumber : Int {
        get {
            self.changeCounter.performedReadOnMainThread(DataModel.sumOfNumberK)
            return _sumOfNumber
        }
        set {
            self.changeCounter.performedWriteOnMainThread(DataModel.sumOfNumberK)
            _sumOfNumber = newValue
        }
    }

    static let invSumOfNumberK = PropertyDescriptor(keypath: \DataModel.invSumOfNumber,
                                                    description: "invSumOfNumber",
                                                    dependFromPropertySet: [DataModel.number1K, DataModel.number2K])

    fileprivate var _invSumOfNumber: Int = 0
    var invSumOfNumber : Int {
        get {
            self.changeCounter.performedReadOnMainThread(DataModel.invSumOfNumberK)
            return _invSumOfNumber
        }
        set {
            self.changeCounter.performedWriteOnMainThread(DataModel.invSumOfNumberK)
            _invSumOfNumber = newValue
        }
    }

    let immediateSumProcessor: ImmediateSumProcessor = ImmediateSumProcessor()
    let delayedSumProcessor: DelayedSumProcessor = DelayedSumProcessor()

//    static let transientClassK = PropertyDescription(
//        keypath: \DataModel.transientClass,
//        description: "transientClass").descriptor()

    fileprivate var _transientClass: TransientClass?
    var transientClass: TransientClass? {
        get {
//            self.changeCounter.performedReadOnMainThread(DataModel.transientClassK)
            return _transientClass
        }
        set {
//            self.changeCounter.performedWriteOnMainThread(DataModel.transientClassK)
            _transientClass = newValue
        }
    }

    // MARK: Standard Initialization

    override init()
    {
        self.repositoryObserver = RepositoryObserver()

        self._number1 = 3
        self._number2 = 4

        super.init()
        self.repositoryObserver.registerRoot(
            associatedObject: self,
            changeCounter: self.changeCounter,
            rootDescription: DataModel.dataModelK)
        self.contextMgr.registerRoot(self)
    }

    func postInit(document: DemoDocument)
    {
        self.document = document

        self.delayedSumProcessor.dataModel = self
        self.delayedSumProcessor.register()
        self.immediateSumProcessor.dataModel = self
        self.immediateSumProcessor.register()
        self.repositoryObserver.refreshUI()
    }

    //MARK: NSCoding Initialization

    // TODO: NSCoding
    //  func encode(with aCoder: NSCoder) {
    //    CodingConverter<Int>.encode(aCoder, value: _number1, propertyDescription: DataModel.number1K)
    //    CodingConverter<Int>.encode(aCoder, value: _number2, propertyDescription: DataModel.number2K)
    //  }
    //
    //  required init?(coder aDecoder: NSCoder) {
    //    self.repositoryObserver = RepositoryObserver()
    //    _number1 = CodingConverter<Int>.decode(aDecoder, propertyDescription: DataModel.number1K) ?? 100
    //    _number2 = CodingConverter<Int>.decode(aDecoder, propertyDescription: DataModel.number2K) ?? 200
    //
    //    super.init()
    //    self.repositoryObserver.registerRoot(
    //      associatedObject: self,
    //      changeCounter: self.changeCounter,
    //      rootDescription: DataModel.dataModelK)
    //    self.contextMgr.registerRoot(self)
    //  }
    
}


//MARK: - Data Model Processing
extension DataModel
{

    //MARK: getSum
    static func getSumKeypaths() -> Set<KeypathDescription> {
        let keypathDescription = KeypathDescription(root: DataModel.dataModelK, chain: [DataModel.sumOfNumberK])
        return [keypathDescription]
    }

    func getSum() -> Int?
    {
        return self.sumOfNumber
    }
}

//MARK: Actions
extension DataModel
{
    func createTransient()
    {
        self.transientClass = TransientClass()
    }

    func removeTransient()
    {
        self.transientClass = nil
    }
}










