//
//  AppDelegate.swift
//  elNoorTask
//
//  Created by Eslam  on 4/23/19.
//  Copyright © 2019 Eslam. All rights reserved.
//

import UIKit
import GoogleMaps
import UserNotifications

let googleApiKey = "YOUR-API-KEY-HERE"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    //to show notification while app is active
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GMSServices.provideAPIKey(googleApiKey)
        UNUserNotificationCenter.current().delegate = self
        // to get the user auth to display notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            print ("granted is: \(granted)")
        }
        return true
    }


}

