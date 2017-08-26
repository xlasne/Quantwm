//
//  QuantwmTest.swift
//  QUANTWM
//
//  Created by Xavier on 31/05/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import XCTest
@testable import QuantwmOSX

class TestStruct: MonitoredNode
{
    func getNodeChangeCounter() -> QWChangeCounter {
        return changeCounter
    }

    let changeCounter = QWChangeCounter()

    static let numberK = PropertyDescriptor(keypath: \TestStruct.number,
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

enum TestEnum
{
    case item1(TestStruct)
    case item2(TestStruct)

    func getTestStruct() -> TestStruct
    {
        switch self
        {
        case .item1(let node):
            return node
        case .item2(let node):
            return node
        }
    }
}


class TestClass: MonitoredClass
{
    func getNodeChangeCounter() -> QWChangeCounter {
        return changeCounter
    }

    let changeCounter = QWChangeCounter()

    static let testStructK = PropertyDescription<TestClass,TestStruct>(
        keypath: \TestClass.testStruct,
        description: "testStruct",
        dependFromPropertySet: []).descriptor()
    fileprivate var _testStruct = TestStruct()
    var testStruct : TestStruct {
        get {
            self.changeCounter.performedReadOnMainThread(TestClass.testStructK)
            return _testStruct
        }
        set {
            self.changeCounter.performedWriteOnMainThread(TestClass.testStructK)
            _testStruct = newValue
        }
    }

    static let testDictK = PropertyDescriptor(
        keypath: \TestClass.testDict,
        sourceType: TestClass.self,
        destType: TestStruct.self,
        description: "testDict",
        getChildArray: { (testClass:MonitoredNode) -> [MonitoredNode] in
            guard let testClass = testClass as? TestClass else { return []}
            let nodeArray = testClass.testDict.values
            return Array(nodeArray) as [MonitoredNode]
            },
        dependFromPropertySet: [])
//    PropertyDescription<TestClass,TestStruct>(
//    keypath: \TestClass.testDict.values,
//        description: "testDict").propertyDescriptor()

    fileprivate var _testDict: [String:TestStruct] = [:]
    var testDict : [String:TestStruct] {
        get {
            self.changeCounter.performedReadOnMainThread(TestClass.testDictK)
            return _testDict
        }
        set {
            self.changeCounter.performedWriteOnMainThread(TestClass.testDictK)
            _testDict = newValue
        }
    }

    static let testEnumK = PropertyDescriptor(
        keypath: \TestClass.testEnum,
        sourceType: TestClass.self,
        destType: MonitoredNode.self,
        description: "testEnum",
        getChildArray: { (testClass:MonitoredNode) -> [MonitoredNode] in
            guard let testClass = testClass as? TestClass else { return []}
            let retVal = testClass.testEnum.getTestStruct() as MonitoredNode
            return [retVal]
    },
        dependFromPropertySet: [])

//    static let testEnumK = PropertyDescriptor<TestClass,TestStruct>.key("_testEnum",
//                                                                        propertyDescriptionOption: [.monitoredNodeGetter,.containsNode]
//    )
    fileprivate var _testEnum = TestEnum.item1(TestStruct())
    var testEnum : TestEnum {
        get {
            self.changeCounter.performedReadOnMainThread(TestClass.testEnumK)
            return _testEnum
        }
        set {
            self.changeCounter.performedWriteOnMainThread(TestClass.testEnumK)
            _testEnum = newValue
        }
    }

}

class TestBase: MonitoredClass, RepositoryHolder
{
    let changeCounter = QWChangeCounter()
    func getNodeChangeCounter() -> QWChangeCounter {
        return changeCounter
    }

    let repositoryObserver = RepositoryObserver()
    func getRepositoryObserver() -> RepositoryObserver
    {
        return repositoryObserver
    }

    static let testRootK = RootDescriptor(sourceType: TestBase.self, description: "testBase")
    var observedSelf: TestBase {
//        changeCounter.performedReadOnMainThread(TestBase.testRootK)
        return self
    }

    static let testClassK = PropertyDescription<TestBase,TestClass>(
        keypath: \TestBase._testClass,
        description: "testClass",
        dependFromPropertySet: []).descriptor()

    fileprivate var _testClass: TestClass
    var testClass : TestClass {
        get {
            self.changeCounter.performedReadOnMainThread(TestBase.testClassK)
            return _testClass
        }
        set {
            self.changeCounter.performedWriteOnMainThread(TestBase.testClassK)
            _testClass = newValue
        }
    }

    static let optNumberK = PropertyDescriptor(keypath: \TestBase.optNumber, description: "optNumber")
    fileprivate var _optNumber: Int? = nil
    var optNumber : Int? {
        get {
            self.changeCounter.performedReadOnMainThread(TestBase.optNumberK)
            return _optNumber
        }
        set {
            self.changeCounter.performedWriteOnMainThread(TestBase.optNumberK)
            _optNumber = newValue
        }
    }

    static let lazyNumberK = PropertyDescriptor(keypath: \TestBase.lazyNumber, description: "lazyNumber")
    fileprivate lazy var _lazyNumber = { () -> (Int) in
        return 3 + 5
    }()
    var lazyNumber : Int {
        get {
            self.changeCounter.performedReadOnMainThread(TestBase.lazyNumberK)
            return _lazyNumber
        }
        set {
            self.changeCounter.performedWriteOnMainThread(TestBase.lazyNumberK)
            _lazyNumber = newValue
        }
    }

    init()
    {
        _testClass = TestClass()

        // End of init

        self.repositoryObserver.registerRoot(
            associatedObject: self,
            changeCounter: self.changeCounter,
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

class QuantwmTest: XCTestCase {

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
        let keypath = KeypathSet(readWithRoot:TestBase.testRootK, chain: [TestBase.testClassK, TestClass.testStructK, TestStruct.numberK])
        let registration = RegisterDescription(selector: #selector(TestCall.testCall),
                                               keypathSet: keypath,
                                               name: "testBasic")
        self.base.getRepositoryObserver().registerObserver(target: testCall,
                                                           registrationDesc: registration)
        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "Initial state")

        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")

        self.base.testClass.testStruct.number = 2

        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "update -> call")
    }

    func testOptionalUpdate() {
        let keypath = KeypathSet(readWithRoot:TestBase.testRootK, chain: [TestBase.optNumberK])
        let registration = RegisterDescription(selector: #selector(TestCall.testCall),
                                               keypathSet: keypath,
                                               name: "testOptionalCall")
        self.base.getRepositoryObserver().registerObserver(target: testCall, registrationDesc: registration)
        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "Initial state")

        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")

        self.base.optNumber = 2
        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "update -> call")

        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")

        self.base.optNumber = 3
        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "update -> call")

        self.base.optNumber = nil
        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "update -> call")

        self.base.optNumber = 3
        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "update -> call")

    }

    func testLazyUpdate() {
        let keypath = KeypathSet(readWithRoot:TestBase.testRootK, chain: [TestBase.lazyNumberK])
        let registration = RegisterDescription(selector: #selector(TestCall.testCall),
                                               keypathSet: keypath,
                                               name: "testLazyCall")
        self.base.getRepositoryObserver().registerObserver(target: testCall, registrationDesc: registration)
        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "Initial state")

        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")

        self.base.lazyNumber = 2
        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "update -> call")

        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")

        self.base.lazyNumber = 3
        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "update -> call")

    }


    func testDictUpdate() {
        let keypath = KeypathSet(readWithRoot:TestBase.testRootK, chain: [TestBase.testClassK, TestClass.testDictK])
        let registration = RegisterDescription(selector: #selector(TestCall.testCall),
                                               keypathSet: keypath,
                                               name: "TestDict")
        self.base.getRepositoryObserver().registerObserver(target: testCall, registrationDesc: registration)
        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "Initial state")

        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")

        self.base.testClass.testDict["toto"] = TestStruct()
        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "update -> call")

        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")
    }

    func testDictUpdate2() {
        let keypath = KeypathSet(readWithRoot:TestBase.testRootK, chain: [TestBase.testClassK, TestClass.testDictK,TestStruct.numberK])
        let registration = RegisterDescription(selector: #selector(TestCall.testCall),
                                               keypathSet: keypath,
                                               name: "testDict2")
        self.base.getRepositoryObserver().registerObserver(target: testCall, registrationDesc: registration)
        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "Initial state")

        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")

        self.base.testClass.testDict["toto"] = TestStruct()
        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "update -> call")

        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")

        self.base.testClass.testDict["toto"]!.number = 3
        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "update -> call")

        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")
    }

    func testEnumUpdate() {
        let keypath = KeypathSet(readWithRoot:TestBase.testRootK, chain: [TestBase.testClassK, TestClass.testEnumK,TestStruct.numberK])
        let registration = RegisterDescription(selector: #selector(TestCall.testCall),
                                               keypathSet: keypath,
                                               name: "testEnum")
        self.base.getRepositoryObserver().registerObserver(target: testCall, registrationDesc: registration)
        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "Initial state")

        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")

        var testStruct = TestStruct()
        testStruct.number = 3
        self.base.testClass.testEnum = TestEnum.item1(testStruct)
        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "update -> call")

        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")

        testStruct.number = 4
        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "update -> call")

        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")

        testStruct = TestStruct()
        testStruct.number = 4
        self.base.testClass.testEnum = TestEnum.item2(testStruct)
        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "update -> call")

        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")

    }

}
