//
//  Tests_Example.swift
//  Tests_Example
//
//  Created by Xavier on 13/12/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest

import Quantwm



class QuantwmTest: XCTestCase {


    class TestStruct: QWNode
    {
        func getPropertyArray() -> [QWProperty] {
            return []
        }

        func getNodeChangeCounter() -> QWCounter {
            return changeCounter
        }

        func getQWCounter() -> QWCounter {
            return changeCounter
        }

        let changeCounter = QWCounter(name:"TestStruct")

        static let numberK = QWProperty(propertyKeypath: \TestStruct.number,
                                        description: "number")
        fileprivate var _number: Int = 1
        var number : Int {
            get {
                self.changeCounter.performedReadOnMainThread(TestStruct.numberK)
                return _number
            }
            set {
                self.changeCounter.performedWriteOnMainThread(TestStruct.numberK)
                _number = newValue
            }
        }
    }

    enum MyEnum
    {
        case item1(TestStruct)
        case item2(TestStruct)

        static func getTestStruct(node: QWNode) -> [QWNode]
        {
            guard let node = node as? MyEnum else { return []}
            switch node
            {
            case .item1(let node2):
                return [node2]
            case .item2(let node2):
                return [node2]
            }
        }
    }


    class MyClass: QWRoot
    {
        func getPropertyArray() -> [QWProperty] {
            return []
        }

        func getQWCounter() -> QWCounter {
            return changeCounter
        }

        let changeCounter = QWCounter(name:"TestClass")

        static let testStructK = QWNodeProperty(keypath: \MyClass.testStruct,
                                            description: "testStruct")
        fileprivate var _testStruct = TestStruct()
        var testStruct : TestStruct {
            get {
                self.changeCounter.performedReadOnMainThread(MyClass.testStructK)
                return _testStruct
            }
            set {
                self.changeCounter.performedWriteOnMainThread(MyClass.testStructK)
                _testStruct = newValue
            }
        }

        static let testDictK = QWNodeProperty(keypath: \MyClass.testDict,
                                          description: "testDict")

        fileprivate var _testDict: [String:TestStruct] = [:]
        var testDict : [String:TestStruct] {
            get {
                self.changeCounter.performedReadOnMainThread( MyClass.testDictK)
                return _testDict
            }
            set {
                self.changeCounter.performedWriteOnMainThread( MyClass.testDictK)
                _testDict = newValue
            }
        }

//            var _myEnum: MyEnum = MyEnum.item1(TestStruct())
//            var myEnum: MyEnum  {
//                get {
//                    self.changeCounter.performedReadOnMainThread( MyClass.testEnumK)
//                    return _myEnum
//                }
//                set {
//                    self.changeCounter.performedWriteOnMainThread( MyClass.testEnumK)
//                    _myEnum = newValue
//                }
//            }
//
//            static let testEnumK = QWNodeProperty(
//                keypath: \MyClass.myEnum,   // <- Swift failure to compile this valid code ???
//                description: "testEnum",
//                sourceType: MyClass.self,
//                destinationType: TestStruct.self,
//                getHandler: { (testClass:QWNode) -> [QWNode] in
//                    guard let testClass = testClass as? TestClass else { return []}
//                    let retVal = testClass.testEnum.getTestStruct() as QWNode
//                    return [retVal]})

    }

    class TestBase: QWRoot, QWMediatorOwner
    {
        let changeCounter = QWCounter(name: "TestBase")
        func getQWCounter() -> QWCounter {
            return changeCounter
        }
        func getPropertyArray() -> [QWProperty] {
            return []
        }

        // QWMediatorOwner Protocol
        let qwMediator = QWMediator()
        func getQWMediator() -> QWMediator
        {
            return qwMediator
        }

        static let testRootK = QWRootProperty(sourceType: TestBase.self, description: "testBase")


        static let testClassK = QWNodeProperty(
            keypath: \TestBase._testClass,
            description: "testClass")

        fileprivate var _testClass: MyClass
        var testClass : MyClass {
            get {
                self.changeCounter.performedReadOnMainThread( TestBase.testClassK)
                return _testClass
            }
            set {
                self.changeCounter.performedWriteOnMainThread( TestBase.testClassK)
                _testClass = newValue
            }
        }

        static let optNumberK = QWProperty(propertyKeypath: \TestBase.optNumber,
                                           description: "optNumber")

        fileprivate var _optNumber: Int? = nil
        var optNumber : Int? {
            get {
                self.changeCounter.performedReadOnMainThread( TestBase.optNumberK)
                return _optNumber
            }
            set {
                self.changeCounter.performedWriteOnMainThread( TestBase.optNumberK)
                _optNumber = newValue
            }
        }

        static let lazyNumberK = QWProperty(propertyKeypath: \TestBase.lazyNumber,
                                            description: "lazyNumber")

        fileprivate lazy var _lazyNumber = { () -> (Int) in
            return 3 + 5
        }()
        var lazyNumber : Int {
            get {
                self.changeCounter.performedReadOnMainThread( TestBase.lazyNumberK)
                return _lazyNumber
            }
            set {
                self.changeCounter.performedWriteOnMainThread( TestBase.lazyNumberK)
                _lazyNumber = newValue
            }
        }

        init()
        {
            _testClass = MyClass()

            // End of init

            qwMediator.registerRoot(associatedObject: self,
                                    rootDescription: TestBase.testRootK)
        }
    }

    class TestCall: NSObject
    {
        var isCalled = false

        @objc func testCall()
        {
            isCalled = true
        }

        func checkIfCalled() -> Bool
        {
            defer {isCalled = false}
            return isCalled
        }
    }


    var base: TestBase = TestBase()
    let testCall = TestCall()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.base = TestBase()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBasicUpdate() {
        let qwPath = QWPath(root: TestBase.testRootK)
            .appending(TestBase.testClassK)
            .appending(MyClass.testStructK)
            .appending(TestStruct.numberK).map

        let registration = QWRegistration(selector: #selector(TestCall.testCall),
                                          readMap: qwPath,
                                          name: "testBasic")
        self.base.getQWMediator().registerObserver(target: testCall,
                                                   registrationDesc: registration)

        self.base.getQWMediator().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "Initial state")

        self.base.getQWMediator().refreshUI()
        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")

        self.base.testClass.testStruct.number = 2

        self.base.getQWMediator().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "update -> call")
    }

    func testOptionalUpdate() {

        let keypath = QWPath(root: TestBase.testRootK)
            .appending(TestBase.optNumberK).map

        let registration = QWRegistration(selector: #selector(TestCall.testCall),
                                          readMap: keypath,
                                          name: "testOptionalCall")

        self.base.getQWMediator().registerObserver(target: testCall, registrationDesc: registration)
        self.base.getQWMediator().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "Initial state")

        self.base.getQWMediator().refreshUI()
        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")

        self.base.optNumber = 2
        self.base.getQWMediator().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "update -> call")

        self.base.getQWMediator().refreshUI()
        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")

        self.base.optNumber = 3
        self.base.getQWMediator().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "update -> call")

        self.base.optNumber = nil
        self.base.getQWMediator().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "update -> call")

        self.base.optNumber = 3
        self.base.getQWMediator().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "update -> call")

    }

    func testLazyUpdate() {
        let keypath = QWPath(root: TestBase.testRootK)
            .appending(TestBase.lazyNumberK).map

        let registration = QWRegistration(selector: #selector(TestCall.testCall),
                                          readMap: keypath,
                                          name: "testLazyCall")
        self.base.getQWMediator().registerObserver(target: testCall, registrationDesc: registration)
        self.base.getQWMediator().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "Initial state")

        self.base.getQWMediator().refreshUI()
        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")

        self.base.lazyNumber = 2
        self.base.getQWMediator().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "update -> call")

        self.base.getQWMediator().refreshUI()
        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")

        self.base.lazyNumber = 3
        self.base.getQWMediator().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "update -> call")

    }


    func testDictUpdate() {
        let keypath = QWPath(root: TestBase.testRootK)
            .appending(TestBase.testClassK)
            .appending(MyClass.testDictK).map

        let registration = QWRegistration(selector: #selector(TestCall.testCall),
                                          readMap: keypath,
                                          name: "TestDict")
        self.base.getQWMediator().registerObserver(target: testCall, registrationDesc: registration)
        self.base.getQWMediator().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "Initial state")

        self.base.getQWMediator().refreshUI()
        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")

        self.base.testClass.testDict["toto"] = TestStruct()
        self.base.getQWMediator().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "update -> call")

        self.base.getQWMediator().refreshUI()
        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")
    }

    func testDictUpdate2() {
        let keypath = QWPath(root: TestBase.testRootK)
            .appending(TestBase.testClassK)
            .appending(MyClass.testDictK)
            .appending(TestStruct.numberK)
            .map

        let registration = QWRegistration(selector: #selector(TestCall.testCall),
                                          readMap: keypath,
                                          name: "testDict2")
        self.base.getQWMediator().registerObserver(target: testCall, registrationDesc: registration)
        self.base.getQWMediator().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "Initial state")

        self.base.getQWMediator().refreshUI()
        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")

        self.base.testClass.testDict["toto"] = TestStruct()
        self.base.getQWMediator().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "update -> call")

        self.base.getQWMediator().refreshUI()
        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")

        self.base.testClass.testDict["toto"]!.number = 3
        self.base.getQWMediator().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "update -> call")

        self.base.getQWMediator().refreshUI()
        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")
    }

//    func testEnumUpdate() {
//        let keypath = QWPath(root:TestBase.testRootK, chain: [TestBase.testClassK, MyClass.testEnumK,TestStruct.numberK]).map
//        let registration = QWRegistration(selector: #selector(TestCall.testCall),
//                                          qwMap: keypath,
//                                          name: "testEnum")
//        self.base.getQWMediator().registerObserver(target: testCall, registrationDesc: registration)
//        self.base.getQWMediator().refreshUI()
//        XCTAssert(testCall.checkIfCalled() == true, "Initial state")
//
//        self.base.getQWMediator().refreshUI()
//        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")
//
//        var testStruct = TestStruct()
//        testStruct.number = 3
//        self.base.testClass.myEnum = MyEnum.item1(testStruct)
//        self.base.getQWMediator().refreshUI()
//        XCTAssert(testCall.checkIfCalled() == true, "update -> call")
//
//        self.base.getQWMediator().refreshUI()
//        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")
//
//        testStruct.number = 4
//        self.base.getQWMediator().refreshUI()
//        XCTAssert(testCall.checkIfCalled() == true, "update -> call")
//
//        self.base.getQWMediator().refreshUI()
//        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")
//
//        testStruct = TestStruct()
//        testStruct.number = 4
//        self.base.testClass.myEnum = MyEnum.item2(testStruct)
//        self.base.getQWMediator().refreshUI()
//        XCTAssert(testCall.checkIfCalled() == true, "update -> call")
//
//        self.base.getQWMediator().refreshUI()
//        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")
//
//    }

}


