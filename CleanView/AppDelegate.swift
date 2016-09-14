//
//  AppDelegate.swift
//  CleanView
//
//  Created by Sanghoon Ahn on 2016. 8. 16..
//  Copyright © 2016년 AHN. All rights reserved.
//
// git hub uploaded really?

import UIKit
import Firebase
import FirebaseInstanceID
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        FIRApp.configure()
        
        // Add observer for InstanceID token refresh callback.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.tokenRefreshNotificaiton), name: kFIRInstanceIDTokenRefreshNotification, object: nil)
        
        
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        return true
    }
    
    // Receive Message
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        if (application.applicationState == UIApplicationState.Inactive) {
            print("######App is Inactive")
            completionHandler(.NewData)
        } else if (application.applicationState == UIApplicationState.Background) {
            print("######App is Background")
            completionHandler(.NewData)
        } else {
            print("######App is Active")
            
            if let tempMessage = userInfo["message"] {
                print("Message : \(tempMessage)")
                
                var hostVC = self.window?.rootViewController
                while let next = hostVC?.presentedViewController {
                    hostVC = next
                }
                
                let alert = UIAlertController(title: "완료 알림", message: "\(tempMessage)", preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "확인", style: .Cancel, handler: nil)
                alert.addAction(cancelAction)
                hostVC!.presentViewController(alert, animated: true, completion: nil)
                
            } else {
                print("message ID Error")
            }
            
            completionHandler(.NewData)
        }
        
        print("Original Message : ", userInfo)
        // Print message ID.
        
        
    }
    
    func tokenRefreshNotificaiton(notification: NSNotification) {
        if let refreshedToken = FIRInstanceID.instanceID().token(){
            print("InstanceID token: \(refreshedToken)")
            
            let url = NSURL(string:"http://52.78.53.87/fcm/register.php")
            let request : NSMutableURLRequest = NSMutableURLRequest(URL: url!)
            let bodydata = "Token=\(refreshedToken)"
            
            request.HTTPMethod = "POST"
            request.HTTPBody = bodydata.dataUsingEncoding(NSUTF8StringEncoding)
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
                data, response, error in
                if error != nil{
                    print("error = \(error)")
                    return
                }
                print("response = \(response)")
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("responseString = \(responseString)")
            }
            task.resume()
            
        } else {
            print("토큰 초기화 안됨--------------")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    func connectToFcm() {
        FIRMessaging.messaging().connectWithCompletion { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        connectToFcm()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    

    func registerForPushNotifications(application: UIApplication){
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .None {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        //Tricky line
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.Unknown)
        print("Device Token:", tokenString)
    }
    
}

