//
//  AppDelegate.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/4/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // The application window.
    var window: UIWindow?

    // Runs when the application first starts.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        DataManager.loadData()
        return true
    }

    // Runs when the application will stop being active.
    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    // Runs when the application will enter the background.
    func applicationDidEnterBackground(_ application: UIApplication) {
        DataManager.saveData()
    }

    // Runs when the application comes back into focus.
    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    // Runs when the application becomes active.
    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    // Runs when the application will be terminated.
    func applicationWillTerminate(_ application: UIApplication) {
        DataManager.saveData()
    }

}

