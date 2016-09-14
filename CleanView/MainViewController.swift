//
//  MainViewController.swift
//  CleanView
//
//  Created by Sanghoon Ahn on 2016. 8. 18..
//  Copyright © 2016년 AHN. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController {

    @IBOutlet var washer1Button: UIButton!
    @IBOutlet var washer2Button: UIButton!
    @IBOutlet var dryer1Button: UIButton!
    @IBOutlet var dryer2Button: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogoutButton(sender: AnyObject) {
        print("로그아웃 되었습니다.")
        let autoLoginInfo = NSUserDefaults.standardUserDefaults()
        if autoLoginInfo.stringForKey("ID") != nil{
            autoLoginInfo.removeObjectForKey("ID")
            autoLoginInfo.removeObjectForKey("PW")
            print("자동 로그인 해제")
        }
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func alertUser(title:String, body:String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "확인", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: false, completion: nil)
    }
    
    @IBAction func onWasher1Button(sender: AnyObject) {
        let deviceNum:Int = 1
        checkDevice(deviceNum)
    }
    @IBAction func onWasher2Button(sender: AnyObject) {
        let deviceNum:Int = 2
        checkDevice(deviceNum)
    }
    @IBAction func onDryer1Button(sender: AnyObject) {
        let deviceNum:Int = 3
        checkDevice(deviceNum)
    }
    @IBAction func onDryer2Button(sender: AnyObject) {
        let deviceNum:Int = 4
        checkDevice(deviceNum)
    }
    
    func checkDevice(deviceNum:Int){
        
        let token = FIRInstanceID.instanceID().token()!
        
        let url = NSURL(string:"http://52.78.53.87/fcm/confirm.php")
        let request : NSMutableURLRequest = NSMutableURLRequest(URL: url!)
        let bodydata = "num=\(deviceNum)&token=\(token)"
        
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
            if (responseString == "1"){
                print("알림 취소")
                let url = NSURL(string:"http://52.78.53.87/fcm/delete.php")
                let request : NSMutableURLRequest = NSMutableURLRequest(URL: url!)
                let bodydata = "num=\(deviceNum)&token=\(token)"
                
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
                    dispatch_async(dispatch_get_main_queue()) {
                        self.alertUser("알림 취소", body: "\(deviceNum)번 세탁기의 알림을 받지 않습니다.")
                    }
                    
                }
                task.resume()
            } else {
                print("알림 받기")
                let url = NSURL(string:"http://52.78.53.87/fcm/laundry.php")
                let request : NSMutableURLRequest = NSMutableURLRequest(URL: url!)
                let bodydata = "num=\(deviceNum)&token=\(token)"
                
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
                    dispatch_async(dispatch_get_main_queue()) {
                        self.alertUser("알림 받기", body: "\(deviceNum)번 세탁기의 알림을 받습니다.")
                    }
                    
                }
                task.resume()
            }
        }
        task.resume()
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
