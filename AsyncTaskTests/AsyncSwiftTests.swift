//
//  AsyncSwiftTests.swift
//  AsyncSwiftTests
//
//  Created by James Yopp on 6/9/14.
//  Copyright (c) 2014 James Yopp. All rights reserved.
//

import XCTest
import AsyncSwift
import UIKit

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
		var tasks = Array<Async<Void>>()
		for i in 1...20 {
			let taskI = Async<Void> {
				usleep(useconds_t(100 * (i % 5 + i % 3 + i % 2)))
				NSLog("Task %i", i)
			}
			tasks.append(taskI)
		}
		var results = tasks.map() {
			(var task) -> Async<Void> in
			task.await();
			return task
		}
		XCTAssert(results.count == tasks.count, "All fanout tasks returned")
	}
	
	func testInstantiationOfDownloadedContent() {
		let url = NSURL(string:"https://www.google.com/images/srpr/logo11w.png")
		
		let instantiationTask = Async<UIImage>( UIImage(data: NSData(contentsOfURL:url)) )
		NSLog("Got image of size %@", NSStringFromCGSize(instantiationTask.await().size))
		
		XCTAssert(instantiationTask.await().size.height > 0, "Created downloaded image in background")
	}
    
}
