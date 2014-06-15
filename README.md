Swift-Async
===========

Sweet syntactic sugar for using an Async-Await pattern with Apple's Swift language. Based on Grand Central Dispatch. Async is a class generic, parameterized on your work's return type, and uses trailing-closure syntax for intense majesty.

###How it works

Simply place `Async<ReturnType>` in front of your code to execute it on a background queue and receive a future for its result. Calling `.await()` on the returned object blocks execution until the result of the block can be synchronously returned. The closure you pass is always scheduled to run immediately and will often be executing by the time the function returns. [See why](#FAQ)

```
let myTask = Async<(result:String, code:Int)> {
  // Do some long running work
  return ("Success", 0)
}

// Do some other stuff

// Finally, block on the result of myTask
let (result, code) = myTask.await()
if code != 0 {
  println("Error: Got \(result)")
}
```
#####Tasks without a return type
To run without returning a value, parameterize on Void. `task.await()` still works normally, but there is no return value.
```
let voidTask = Async<Void> {
  // Just do the long-running work and don't return a value
}
```

##### Asynchronous Dependencies

Async's `.await()` function comes in two flavors. Calling `.await()` with no parameters will wait synchronously, on the current queue, for the return value. Calling `.await( (T) -> (OtherT) )` returns a new `Async<OtherT>` whose execution will begin when the input value becomes available:

_This code is taken from [AppDelegate.swift](AsyncSwift/AppDelegate.swift) in the sample project_
```
let url = NSURL(string:"http://placehold.it/250x300&text=Async+Download")
let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
let filePath = path.stringByAppendingPathComponent("cached.png")

// Load the data from disk if available, or from the network otherwise. 
let fetchData = Async<(data:NSData, fromCache:Bool)> {
	if (NSFileManager.defaultManager().fileExistsAtPath(filePath)) {
		return (NSData(contentsOfFile: filePath), true)
	} else {
		return (NSData(contentsOfURL: url), false)
	}
}
// Create a UIImage resource from the data on the default queue
let decodeImage = fetchData.await() {
	UIImage(data: $0.data)
}
// When image decode is complete, assign it to an image on the main thread
decodeImage.await(dispatch_get_main_queue()) {
	imageView.image = $0
	imageView.frame = controller.view.bounds
	controller.view.addSubview(imageView)
	println("Set Image")
}
// When the data is available (in parallel with decode), ensure it's saved to disk.
let saveToCache = fetchData.await() {
	(let input:(data:NSData, fromCache:Bool)) -> Bool in
	return input.fromCache ? true : input.data.writeToFile(filePath, atomically:true)
}
// Show the user the status of the cache save on the main thread.
saveToCache.await(dispatch_get_main_queue()) {
	let cached = $0 ? "Cached" : "Uncached"
	println("File is now: \(cached)")
}
```

#####Member functions
Async can be created with a member function rather than a closure, as long as the function does not expect any arguments:
```
let memberTask = Async<MyObject>(self.generateDefaultObject)
```
#####Implicit Closures
For expressions, including any calls to member functions or initializers that do accept arguments, simply pass the expression in the parentheses:
```
let memberTask2 = Async<MyObject>(self.generate(foo:"Bar"))

let assignTask = Async<Void>(object.field = LengthyProcessing(value))

let initTask = Async<MyObject>(MyObject(foo:"Bar"))
```
#####Specifying a Queue
Pass a GCD queue to do work on a specific queue:
```
Async<Void>(dispatch_get_main_queue(), myImageView.image = processedImage)
```

### <a name="FAQ"></a>FAQ and Design Considerations

##### Why do tasks start running immediately?

In short, it drastically simplifies the synchronization model favored by Async. There is much less state to track, and many fewer opportunities for bugs or unexpected side-effects. See [Async.swift](AsyncSwift/Async.swift)

Running tasks immediately covers the cases Async was designed for. There are cases where this is undesirable, but Swift's function declaration syntax supports those cases rather well. Adding additional argument lists to a functon's declaration will cause all preceding argument lists to return a closure over the entire function; call the resulting closure with the second parameter list to cause it to execute.

```
// Each preceding argument list binds the supplied variables and returns a closure for the remaining bits.
func myDelayedCalculation(result:String, code:Int)() -> String {
	return code == 0 ? result : "Error"
}
let boundClosure = myDelayedCalculation(result:"Super!", code:0)
let finalString = boundClosure()
```

##### How does Async actually work?

Async creates an object with a dispatch_sempaphore that begins in a blocked state. The semaphore is unlocked when the work closure completes. From then on, each call to .await() will wait on the semaphore (eg, take the lock), grab the value, then signal the semaphore (release the lock) before returning.
