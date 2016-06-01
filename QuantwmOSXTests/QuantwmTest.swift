//
//  QuantwmTest.swift
//  QUANTWM
//
//  Created by Xavier on 31/05/16.
//  Copyright © 2016 XL Software Solutions. All rights reserved.
//

import XCTest
@testable import QuantwmOSX

class TestStruct: MonitoredStruct
{
    let changeCounter = ChangeCounter()

    static let numberK = PropertyDescriptor<TestStruct,Int>.key("_number")
    private var _number: Int = 1
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
        case item1(let node):
            return node
        case item2(let node):
            return node
        }
    }
}


class TestClass: MonitoredClass, MonitoredNodeGetter
{
    let changeCounter = ChangeCounter()

    static let testStructK = PropertyDescriptor<TestClass,TestStruct>
        .key("_testStruct", propertyDescriptionOption: [.ContainsNode])
    private var _testStruct = TestStruct()
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

    static let testDictK = PropertyDescriptor<TestClass,TestStruct>.key("_testDict",
                propertyDescriptionOption: [.MonitoredNodeGetter,.ContainsNode]
                                                                )
    private var _testDict: [String:TestStruct] = [:]
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

    static let testEnumK = PropertyDescriptor<TestClass,TestStruct>.key("_testEnum",
                                propertyDescriptionOption: [.MonitoredNodeGetter,.ContainsNode]
    )
    private var _testEnum = TestEnum.item1(TestStruct())
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

    func getMonitoredNodeArray(property: PropertyDescription) -> [MonitoredNode] {
        switch property {
        case TestClass.testDictK:
            let retVal = testDict.values.map({$0 as MonitoredNode})
            return Array(retVal)
        case TestClass.testEnumK:
            let retVal = testEnum.getTestStruct() as MonitoredNode
            return [retVal]
        default:
            assert(false,"Error: Missing case for property \(property.propKey) configured as MonitoredNodeGetter")
            return []
        }
    }
}

class TestBase: MonitoredClass, RepositoryHolder
{
    let changeCounter = ChangeCounter()
    let repositoryObserver = RepositoryObserver()

    func getRepositoryObserver() -> RepositoryObserver
    {
        return repositoryObserver
    }

    static let testRootK = RootDescriptor<TestBase>.key("testBase")
    var observedSelf: TestBase {
        changeCounter.performedReadOnMainThread(TestBase.testRootK)
        return self
    }

    static let testClassK = PropertyDescriptor<TestBase,TestClass>.key("_testClass",
                                                propertyDescriptionOption: [.ContainsNode])
    private var _testClass: TestClass
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

    func testCall()
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
        let keypath = KeypathDescription(root:TestBase.testRootK, chain: [TestBase.testClassK, TestClass.testStructK,TestStruct.numberK])
        let registration = RegisterDescription(selector: #selector(TestCall.testCall),
                                               keypathDescriptionSet: [Set([keypath])],
                                               name: "testCall")
        self.base.getRepositoryObserver().register(target: testCall, registrationDesc: registration)
        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "Initial state")

        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == false, "no update -> no call")

        self.base.testClass.testStruct.number = 2

        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.checkIfCalled() == true, "update -> call")
    }

    func testDictUpdate() {
        let keypath = KeypathDescription(root:TestBase.testRootK, chain: [TestBase.testClassK, TestClass.testDictK])
        let registration = RegisterDescription(selector: #selector(TestCall.testCall),
                                               keypathDescriptionSet: [Set([keypath])],
                                               name: "testCall")
        self.base.getRepositoryObserver().register(target: testCall, registrationDesc: registration)
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
        let keypath = KeypathDescription(root:TestBase.testRootK, chain: [TestBase.testClassK, TestClass.testDictK,TestStruct.numberK])
        let registration = RegisterDescription(selector: #selector(TestCall.testCall),
                                               keypathDescriptionSet: [Set([keypath])],
                                               name: "testCall")
        self.base.getRepositoryObserver().register(target: testCall, registrationDesc: registration)
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
        let keypath = KeypathDescription(root:TestBase.testRootK, chain: [TestBase.testClassK, TestClass.testEnumK,TestStruct.numberK])
        let registration = RegisterDescription(selector: #selector(TestCall.testCall),
                                               keypathDescriptionSet: [Set([keypath])],
                                               name: "testCall")
        self.base.getRepositoryObserver().register(target: testCall, registrationDesc: registration)
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

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
