//
//  AsyncSwiftTests.swift
//  AsyncSwiftTests
//
//  Created by James Yopp on 6/9/14.
//  Copyright (c) 2014 James Yopp. All rights reserved.
//

import XCTest
import AsyncSwift

class AsyncSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(AsyncTester.runTest(), "Basic Async Tests Passed")
    }
	
	func testFanout() {
		var tasks = Array<Async<Any>>()
		for i in 1..20 {
			let taskI = Async<Void> {
				usleep(useconds_t(100 * (i % 5 + i % 3 + i % 2)))
				NSLog("Task %i", i)
			}
		}
		var results = tasks.map { $0.await() }
		XCTAssert(results.count == tasks.count, "All fanout tasks returned")
	}
    
}
