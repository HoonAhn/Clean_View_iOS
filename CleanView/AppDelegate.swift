//
//  AppDelegate.swift
//  CleanView
//
//  Created by Sanghoon Ahn on 2016. 8. 16..
//  Copyright © 2016년 AHN. All rights reserved.
//
// git hub uploaded really? yeah

import UIKit
import Firebase
import FirebaseInstanceID
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

//    override init() {
//        super.init()
//    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FIRApp.configure()
        
        // Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotificaiton), name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
        
        
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        return true
    }
    
    // Receive Message
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        
//        if (application.applicationState == UIApplicationState.inactive) {
//            print("######App is Inactive")
//            completionHandler(.newData)
//        } else if (application.applicationState == UIApplicationState.background) {
//            print("######App is Background")
//            completionHandler(.newData)
//        } else {
//            print("######App is Active")
//            completionHandler(.newData)
//        }
        if let tempMessage = userInfo["aps"], let tempbody = userInfo["body"]{
            
            print("Message : \(tempMessage)")
            
            var hostVC = self.window?.rootViewController
            while let next = hostVC?.presentedViewController {
                hostVC = next
            }
            
            let alert = UIAlertController(title: "완료 알림", message: "\(tempbody as! String)", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "확인", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            hostVC!.present(alert, animated: true, completion: nil)
 
        } else {
            print("message ID Error")
        }
        
        print("Original Message : ", userInfo)
        
    }
    
    func tokenRefreshNotificaiton(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token(){
            print("InstanceID token: \(refreshedToken)")
            
            let url = URL(string:"http://52.78.53.87/fcm/register.php")
            var request = URLRequest(url: url!)
            let bodydata = "Token=\(refreshedToken)"
            
            request.httpMethod = "POST"
            request.httpBody = bodydata.data(using: String.Encoding.utf8)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                data, response, error in
                if error != nil{
                    print("error = \(error)")
                    return
                }
                print("response = \(response)")
                let responseString = String(data: data!, encoding: String.Encoding.utf8)
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
        FIRMessaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        connectToFcm()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    

    func registerForPushNotifications(_ application: UIApplication){
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != UIUserNotificationType() {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        print("%%%%%%%%%%  didRegisterForRemoteNotificationsWithDeviceToken")
        //Tricky line
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.unknown)
        print("Device Token:", tokenString)
    }
    
}

