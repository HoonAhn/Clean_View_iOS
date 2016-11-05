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
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // print("******** didFinishLaunchingWithOptions called")
        // new test
        FIRApp.configure()
        
        //create the notificationCenter
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            // set the type as sound or badge
            center.requestAuthorization(options: [.sound,.alert,.badge]) { (granted, error) in
                // Enable or disable features based on authorization
                
            }
            application.registerForRemoteNotifications()

        } else {
            // Fallback on earlier versions
            NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotificaiton), name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
            
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        
        return true
    }
    
    // Receive Message
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let tempMessage = userInfo["aps"] as? [String:Any],
            let alertContent = tempMessage["alert"] as? [String:String],
            let bodyAlert = alertContent["body"] {
            
            let alarmBool = UserDefaults.standard
            
            if (bodyAlert.hasPrefix("1")) {
                alarmBool.set(0, forKey: "device1")
            } else if (bodyAlert.hasPrefix("2")) {
                alarmBool.set(0, forKey: "device2")
            }
            
            var hostVC = self.window?.rootViewController
            while let next = hostVC?.presentedViewController {
                hostVC = next
            }
            let alert = UIAlertController(title: "완료 알림", message: "\(bodyAlert)", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "확인", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            hostVC!.present(alert, animated: true, completion: nil)
            
        } else {
            print("message ID Error")
            print("Original Message : ", userInfo)
        }
    }
    
    // test
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //print("Handle push from background or closed")
        // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
//        print("\(response.notification.request.content.userInfo)")
        if let tempMessage = response.notification.request.content.userInfo["aps"] as? [String:Any],
            let alertContent = tempMessage["alert"] as? [String:String],
            let bodyAlert = alertContent["body"] {
            
            let alarmBool = UserDefaults.standard
            
            if (bodyAlert.hasPrefix("1")) {
                alarmBool.set(0, forKey: "device1")
            } else if (bodyAlert.hasPrefix("2")) {
                alarmBool.set(0, forKey: "device2")
            }
            
        } else {
            print("message ID Error")
            print("Original Message : ", response.notification.request.content.userInfo)
        }
    }
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //print("Handle push from foreground")
        // custom code to handle push while app is in the foreground
//        print("\(notification.request.content.userInfo)")
        
        if let tempMessage = notification.request.content.userInfo["aps"] as? [String:Any],
            let alertContent = tempMessage["alert"] as? [String:String],
            let bodyAlert = alertContent["body"] {
            
            let alarmBool = UserDefaults.standard
            
            if (bodyAlert.hasPrefix("1")) {
                alarmBool.set(0, forKey: "device1")
            } else if (bodyAlert.hasPrefix("2")) {
                alarmBool.set(0, forKey: "device2")
            }
            
            var hostVC = self.window?.rootViewController
            while let next = hostVC?.presentedViewController {
                hostVC = next
            }
            let alert = UIAlertController(title: "완료 알림", message: "\(bodyAlert)", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "확인", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            hostVC!.present(alert, animated: true, completion: nil)
            
        } else {
            print("message ID Error")
            print("Original Message : ", notification.request.content.userInfo)
        }

    }
    
    //
    
    func tokenRefreshNotificaiton(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token(){
            //print("InstanceID token: \(refreshedToken)")
            
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
                //print("responseString = \(responseString)")
            }
            task.resume()
            
        } else {
            print("token initiate error")
            return
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
        
        DispatchQueue.main.async {
            self.getAlarmInfoFromServer(deviceNum: 1)
            self.getAlarmInfoFromServer(deviceNum: 2)
        }
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        //Tricky line
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.unknown)
        //print("Device Token:", tokenString)
    }
    
    func getAlarmInfoFromServer(deviceNum:Int) {
        // 세탁기는 푸쉬 알림
        let token = FIRInstanceID.instanceID().token()!
        
        let url = URL(string:"http://52.78.53.87/fcm/confirm.php")
        var request = URLRequest(url: url!)
        let bodydata = "num=\(deviceNum)&token=\(token)"
        
        request.httpMethod = "POST"
        request.httpBody = bodydata.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            if error != nil{
                print("error = \(error)")
                return
            }
            //                print("response = \(response)")
            let responseString = String(data: data!, encoding: String.Encoding.utf8)
            // print("responseString = \(responseString)")
            if (responseString == "0"){
                //print("알림 세팅")
                let alarmBool = UserDefaults.standard
                alarmBool.set(0, forKey: "device\(deviceNum)")
            }
        }
        task.resume()
        
    }
    
}

