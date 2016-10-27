//
//  AppDelegate.swift
//  Brilliant
//
//  Created by Paul Berry on 09/20/2015.
//  Copyright (c) 2015 Paul Berry. All rights reserved.
//

import UIKit
import Brilliant

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let prodKey = "ZoNY4M9uqp6PMjbPm6zAee-bVLqkKwelovjOMxxY5xe0CheM71HRtLYBgFNzYMRCtnHKHAq3OTFKcw8hoKCpjQ"
    let devKey = "jZb5h7o_KQwFgKwa7c90yrEV3ibSahqjwYm1rrkYHdZdXcM6fiVADOzC5-CVe7sOKR9YZV8QI_M6L_AJg7w-6Q"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
      // Setup User Info
        Brilliant.createInstance(prodKey, appStoreId: "1057019707", userId: "5", userType: "Free", userDate: Date.distantPast)
        
//        Brilliant.sharedInstance().configureButtonColors(UIColor.redColor())
//        Brilliant.sharedInstance().configureFontName("Times New Roman")
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

