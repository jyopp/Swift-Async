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

class Async<T> {
	let semaphore = dispatch_semaphore_create(0)
	// result should be of type t; However, this is unsupported by IRGen at the moment
	var result: Any = nil {
		didSet {
			dispatch_semaphore_signal(semaphore)
		}
	}
	
	init(_ queue: dispatch_queue_t, _ workClosure:Void->T) {
		dispatch_async(queue) {
			self.result = workClosure()
		}
	}
	convenience init(_ priority: dispatch_queue_priority_t, _ workClosure:Void->T) {
		self.init(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), workClosure)
	}
	convenience init(_ workClosure:Void->T) {
		self.init(DISPATCH_QUEUE_PRIORITY_DEFAULT, workClosure)
	}

	func await() -> T {
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		return result as T
	}
}
