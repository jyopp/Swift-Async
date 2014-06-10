Swift-Async
===========

Sweet syntactic sugar for using an Async-Await pattern with Apple's Swift language. Based on Grand Central Dispatch.

The Async class is parameterized on your work's return type, and uses trailing-closure syntax for intense majesty.

###Example Syntax
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

It is also possible to set up Async work with no return value, or to pass objects' member functions instead of a closure.

```
let voidTask = Async<Void> {
  // Just do the long-running work and don't return a value
}

let memberTask = Async<MyObject>(self.generatorWithNoParams)

let memberTask2 = Async<MyObject> {
  return self.generator(param1:"Label", param2:"Subhead")
}
```
