//
//  AsyncTester.swift
//  AsyncSwift
//
//  Created by James Yopp on 6/9/14.
//  Copyright (c) 2014 James Yopp. All rights reserved.
//

import Foundation

func printOnMainThread(str:String) {
	// This is used because println isn't threadsafe. All output will be delayed, but it won't be munged.
	dispatch_async(dispatch_get_main_queue()) {
		println(str)
	}
}

class AsyncTester {
	
	init () {
	}
	
	var testValue = ""
	
	class func runTest() -> Bool {
		// Create a tester, get a task that depends on several others,
		// and ensure that the tasks returned success and stored a value on the tester object
		let tester = AsyncTester()
		let success = tester.test().await()
		let successStr = success ? "success" : "failure"
		printOnMainThread("Got test \(successStr) with test value: \(tester.testValue)")
		return success
	}
	
	func memberVoid() {
		testValue = "Test Value"
		printOnMainThread("Member void task ran")
	}
	
	func test() -> Async<Bool> {
		
		// Start a task that will spawn another at its end
		let stringTask = Async<(result:String, errorCode:Int)> {
			for _ in 1..20 {
				usleep(100)
				printOnMainThread(".")
			}

			// This task is allowed to run; We don't await it.
			let voidTask = Async<Void>(self.memberVoid)
			
			return ("Done!", 0)
		}
		
		// Start a second task that concatenates its return value with the first's
		let otherStringTask = Async<String?> {
			for _ in 1..10 {
				usleep(600)
				printOnMainThread("/")
			}
			return stringTask.await().result + " and Done!"
		}
		
		printOnMainThread("Started Tasks!")
		// Return a task that awaits the second one
		return Async<Bool> {
			// Multiple callers can call await() from different threads
			if 0 == stringTask.await().errorCode {
				if let result = otherStringTask.await() {
					printOnMainThread("Waited for \(result)")
					return true
				} else {
					printOnMainThread("Waited for no result")
					return false
				}
			} else {
				printOnMainThread("String Task returned error \(stringTask.await().errorCode)")
				return false
			}
		}
	}
}