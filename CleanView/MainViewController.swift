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
    
    @IBOutlet var dryer1StatusLabel: UILabel!
    @IBOutlet var dryer2StatusLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UserDefaults 에 저장된 딕셔너리를 불러와 세탁기의 상태 파악
        
        DispatchQueue.main.async {
            self.getDeviceInfoFromServer()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogoutButton(_ sender: AnyObject) {
        print("로그아웃 되었습니다.")
        let autoLoginInfo = UserDefaults.standard
        if autoLoginInfo.string(forKey: "ID") != nil{
            autoLoginInfo.removeObject(forKey: "ID")
            autoLoginInfo.removeObject(forKey: "PW")
        }
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func alertUser(_ title:String, body:String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: false, completion: nil)
    }
    
    @IBAction func onWasher1Button(_ sender: AnyObject) {
        let deviceNum:Int = 1
        checkDevice(deviceNum)
    }
    @IBAction func onWasher2Button(_ sender: AnyObject) {
        let deviceNum:Int = 2
        checkDevice(deviceNum)
    }
    @IBAction func onDryer1Button(_ sender: AnyObject) {
        let deviceNum:Int = 3
        checkDevice(deviceNum)
    }
    @IBAction func onDryer2Button(_ sender: AnyObject) {
        let deviceNum:Int = 4
        checkDevice(deviceNum)
    }
    
    func checkDevice(_ deviceNum:Int){
        
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
            print("response = \(response)")
            let responseString = String(data: data!, encoding: String.Encoding.utf8)
            print("responseString = \(responseString)")
            if (responseString == "1"){
                print("알림 취소")
                let url = URL(string:"http://52.78.53.87/fcm/delete.php")
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
                    print("response = \(response)")
                    let responseString = String(data: data!, encoding: String.Encoding.utf8)
                    print("responseString = \(responseString)")
                    DispatchQueue.main.async {
                        self.alertUser("알림 취소", body: "\(deviceNum)번 세탁기의 알림을 받지 않습니다.")
                    }
                    
                }
                task.resume()
            } else {
                print("알림 받기")
                let url = URL(string:"http://52.78.53.87/fcm/laundry.php")
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
                    print("response = \(response)")
                    let responseString = String(data: data!, encoding: String.Encoding.utf8)
                    print("responseString = \(responseString)")
                    DispatchQueue.main.async {
                        self.alertUser("알림 받기", body: "\(deviceNum)번 세탁기의 알림을 받습니다.")
                    }
                    
                }
                task.resume()
            }
        }
        task.resume()
    }
    
    func getDeviceInfoFromServer() {
        let urlString = "http://52.78.53.87/timer/status.php"
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
            if error != nil {
                print(error)
            } else {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                    
                    print("Overview of Parsed Data : \(parsedData)")
                    
                    if let resultArray = parsedData["result"] as? [[String:Any]] {
                        
                        if let dicOfNum1 = resultArray[0] as? [String:Any],
                            let dicOfNum2 = resultArray[1] as? [String:Any],
                            let dicOfNum3 = resultArray[2] as? [String:Any],
                            let dicOfNum4 = resultArray[3] as? [String:Any] {
                            
                            if let statusOfNum1 = dicOfNum1["status"] as? String,
                                let finishTimeOfNum1 = dicOfNum1["time"] as? String {
                                print("1번 세탁기 정보 : 상태 = \(statusOfNum1) 완료 시간 = \(finishTimeOfNum1)")
                            } else {
                                print("1번 오류")
                            }
                            if let statusOfNum2 = dicOfNum2["status"] as? String,
                                let finishTimeOfNum2 = dicOfNum2["time"] as? String {
                                print("2번 세탁기 정보 : 상태 = \(statusOfNum2) 완료 시간 = \(finishTimeOfNum2)")
                            } else {
                                print("2번 오류")
                            }
                            if let statusOfNum3 = dicOfNum3["status"] as? String {
                                print("1번 건조기 정보 : 상태 = \(statusOfNum3)")
                            } else {
                                print("3번 오류")
                            }
                            if let statusOfNum4 = dicOfNum4["status"] as? String {
                                print("2번 건조기 정보 : 상태 = \(statusOfNum4)")
                            } else {
                                print("4번 오류")
                            }
                        } else {
                            print("resultArray에서 dicOfNum 가져오는데서 오류")
                        }
                    } else {
                        print("result를 JSON에서 파싱하는데서 오류")
                    }
                } catch {
                    print("*****JSON Parsing Error Occur!!*****")
                }
                
            }
        }).resume()
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
