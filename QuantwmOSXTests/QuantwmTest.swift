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

class TestClass: MonitoredClass
{
    let changeCounter = ChangeCounter()

  static let testStructK = PropertyDescriptor<TestClass,TestStruct>.key("_testStruct",
                                                propertyDescriptionOption: [.ContainsNode])
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
        self.isCalled = true
    }

    func reset()
    {
        self.isCalled = false
    }

}


class QuantwmTest: XCTestCase {

    var base: TestBase = TestBase()
    let testCall = TestCall()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.base = TestBase()
        let keypath = KeypathDescription(root:TestBase.testRootK, chain: [TestBase.testClassK, TestClass.testStructK,TestStruct.numberK])
        let registration = RegisterDescription(selector: #selector(TestCall.testCall),
                                               keypathDescriptionSet: [Set([keypath])],
                                               name: "testCall")
        self.base.getRepositoryObserver().register(target: testCall, registrationDesc: registration)
        self.base.getRepositoryObserver().refreshUI()
        self.testCall.reset()

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBasicUpdate() {

        XCTAssert(testCall.isCalled == false, "Initial state")
        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.isCalled == false, "no update -> no call")

        self.base.testClass.testStruct.number = 2

        self.base.getRepositoryObserver().refreshUI()
        XCTAssert(testCall.isCalled == true, "update -> call")
    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
