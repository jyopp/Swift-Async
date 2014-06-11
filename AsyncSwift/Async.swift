//
//  Async.swift
//  AsyncSwift
//
//  Created by James Yopp on 6/9/14.
//  Copyright (c) 2014 James Yopp. All rights reserved.
//

/** This class must be parameterized on the return type of the closure or function to be executed.
  It can be initialized with a GCD Queue, a global queue priority, or with no arguments.
  If no arguments are passed to the initializer, the default-priority global queue will be used.
*/

import Foundation

let defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

class Async<T> {
	let semaphore = dispatch_semaphore_create(0)
	// result should be of type t; However, this is unsupported by IRGen at the moment
	var result: Any = nil {
		didSet {
			dispatch_semaphore_signal(semaphore)
		}
	}
	
	init(queue: dispatch_queue_t, closure: Void->T) {
		dispatch_async(queue) {
			self.result = closure()
		}
	}
	convenience init(priority: dispatch_queue_priority_t, _ workClosure: Void->T) {
		self.init(queue:dispatch_get_global_queue(priority, 0), workClosure)
	}
	convenience init(_ workClosure: Void->T) {
		self.init(queue:defaultQueue, workClosure)
	}
	
	// Capture auto-closure arguments, such as Async<MyObject>(Constructor(params))
	convenience init(queue: dispatch_queue_t, _ workClosure: @auto_closure ()->T) {
		self.init(queue:queue, closure:workClosure)
	}
	convenience init(priority: dispatch_queue_priority_t, _ workClosure: @auto_closure ()->T) {
		self.init(queue:dispatch_get_global_queue(priority, 0), closure:workClosure)
	}
	convenience init(_ workClosure: @auto_closure ()->T) {
		self.init(queue:defaultQueue, closure:workClosure)
	}
	
	func await() -> T {
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		let rVal = result as T
		// Unblock the next invocation of await()
		dispatch_semaphore_signal(semaphore)
		return rVal
	}
}
