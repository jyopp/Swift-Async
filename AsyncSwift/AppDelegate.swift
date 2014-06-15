//
//  AppDelegate.swift
//  AsyncTask
//
//  Created by James Yopp on 6/9/14.
//  Copyright (c) 2014 James Yopp. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
		self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
		// Override point for customization after application launch.
		self.window!.backgroundColor = UIColor.whiteColor()
		self.window!.makeKeyAndVisible()
		
		
		// Run the test from here, too, so the logs are easy to find
		AsyncTester.runTest()
		
		let controller = UIViewController()
		self.window!.rootViewController = controller

		let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
		imageView.contentMode = UIViewContentMode.Center

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
		println("Returning from initializer")

		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

