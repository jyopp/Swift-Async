Swift-Async
===========

Sweet syntactic sugar for using an Async-Await pattern with Apple's Swift language. Based on Grand Central Dispatch. Async is a class generic, parameterized on your work's return type, and uses trailing-closure syntax for intense majesty.

###How it works

Simply place `Async<ReturnType>` in front of your code to execute it on a background queue and receive a future for its result. Calling `.await()` on the returned object blocks execution until the result of the block can be synchronously returned.
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

#####Implicit closures and passing member functions
Async also supports implicit closures and member functions with no parameters:
```
// Pass a member function that takes no params:
let memberTask = Async<MyObject>(self.generateDefaultObject)
// Pass any other expression to create an implicit closure:
let memberTask2 = Async<MyObject>(self.generate(param1:"Label", param2:"Subhead"))
let (object1, object2) = (memberTask.await, memberTask2.await)
```
#####Specifying a Queue
Pass a GCD queue to do work on a specific queue:
```
Async<Void>(dispatch_get_main_queue(), myImageView.setImage(processedImage))
```
#####Asynchronous callbacks
Use `.asyncAwait()` to have a block called asynchronously on the main queue with the task's result. You may call .asyncAwait as many times as you like and from any queue:
```
let downloadImage = Async<UIImage>( UIImage(data: NSData(contentsOfURL:url)) )
self.imageView = UIImageView(frame: defaultFrame)
downloadImage.asyncAwait() {
  (var image) in
  self.imageView.image = image
}
downloadImage.asyncAwait() {
  (var image) in
  MyImageCache.register(url, image:image)
}
```
