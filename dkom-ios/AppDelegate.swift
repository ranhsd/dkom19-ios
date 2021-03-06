//
//  AppDelegate.swift
//  dkom-ios
//
//  Created by Ran Hassid on 08/01/2019.
//  Copyright © 2019 Trench Girls LTD. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let config = ParseClientConfiguration {
            $0.server = "http://104.197.245.229/"
            $0.applicationId = "myAppId"
            $0.isLocalDatastoreEnabled = false
        }
        
        Parse.initialize(with: config)
        
        if PFUser.current() == nil {
            self.presentWelcomeScreen()
        } else {
            self.presentHome()
        }
        
        // subscribe to observers
        
        NotificationCenter.default.addObserver(self, selector: #selector(showHome(notification:)), name: .registered, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showHome(notification:)), name: .loggedIn, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showWelcome(notification:)), name: .loggedOut, object: nil)
        
        return true
    }
    
    
    //    MARK: Home view controller presentation
    
    @objc func showHome(notification: NSNotification) {
        self.presentHome()
    }
    
    private func presentHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registerController = storyboard.instantiateViewController(withClass: HomeViewController.self)
        let navigationController = UINavigationController(rootViewController: registerController!)
        self.window?.rootViewController = navigationController
    }
    
    //    MARK: Welcome view controller presentation
    
    @objc func showWelcome(notification: NSNotification) {
        self.presentWelcomeScreen()
    }
    
    private func presentWelcomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registerController = storyboard.instantiateViewController(withClass: WelcomeViewController.self)
        let navigationController = UINavigationController(rootViewController: registerController!)
        self.window?.rootViewController = navigationController
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

