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

    @IBOutlet var washer1View: UIView!
    @IBOutlet var washer2View: UIView!
    @IBOutlet var dryer1View: UIView!
    @IBOutlet var dryer2View: UIView!
    
    @IBOutlet var washer1ProgressBarView: CircleProgressView!
    @IBOutlet var washer2ProgressBarView: CircleProgressView!
    @IBOutlet var dryer1ProgressBarView: CircleProgressView!
    @IBOutlet var dryer2ProgressBarView: CircleProgressView!
    
    @IBOutlet var washer1Button: UIButton!
    @IBOutlet var washer2Button: UIButton!
    
    @IBOutlet var washer1NameLabel: UILabel!
    @IBOutlet var washer2NameLabel: UILabel!
    @IBOutlet var dryer1NameLabel: UILabel!
    @IBOutlet var dryer2NameLabel: UILabel!
    
    @IBOutlet var washer1PercentLabel: UILabel!
    @IBOutlet var washer2PercentLabel: UILabel!
    
    @IBOutlet var washer1StatusLabel: UILabel!
    @IBOutlet var washer2StatusLabel: UILabel!
    @IBOutlet var dryer1StatusLabel: UILabel!
    @IBOutlet var dryer2StatusLabel: UILabel!
    
    let NF = NumberFormatter()
    let DF = DateFormatter()
    var timer: Timer?
    var timer2: Timer?
    let washerDuration:Double = 40 * 60 // 세탁 시간 35분을 초단위로 표현
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var multiplier = 1.0
    var alarmBool = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let numOfPlaces = 2.0
        multiplier = pow(10.0, numOfPlaces)
        
        // Do any additional setup after loading the view.
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        self.getDeviceInfoFromServer()
        self.changeEveryAlarmButton()
//        DispatchQueue.main.async {
//        
//        }
        washer1View.layer.cornerRadius = 7
        washer2View.layer.cornerRadius = 7
        dryer1View.layer.cornerRadius = 7
        dryer2View.layer.cornerRadius = 7
        
        washer1NameLabel.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor(red: 0.85, green: 0.858, blue: 0.854, alpha: 1.0), thickness: 2)
        washer2NameLabel.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor(red: 0.85, green: 0.858, blue: 0.854, alpha: 1.0), thickness: 2)
        dryer1NameLabel.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor(red: 0.85, green: 0.858, blue: 0.854, alpha: 1.0), thickness: 2)
        dryer2NameLabel.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor(red: 0.85, green: 0.858, blue: 0.854, alpha: 1.0), thickness: 2)
        
        NF.numberStyle = NumberFormatter.Style.percent
        NF.maximumFractionDigits = 2
        
        DF.dateFormat = "yyyy-MM-dd HH:mm:ss"
        DF.locale = Locale(identifier: "ko_KR")
        DF.timeZone = TimeZone(identifier: "KST")
        
        activityIndicator.isHidden = true
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)

    }

    override func viewDidAppear(_ animated: Bool) {
        
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(MainViewController.getDeviceInfoFromServer), userInfo: nil, repeats: true)
        timer2 = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(MainViewController.changeEveryAlarmButton), userInfo: nil, repeats: true)
        // 세탁기를 예약한 내역
        // UserDefaults 에 저장된 딕셔너리를 불러와 세탁기의 상태 파악
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alertUser(_ title:String, body:String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: false, completion: nil)
    }
    
    @IBAction func onWasher1Button(_ sender: AnyObject) {
        let deviceNum:Int = 1
        alarmCheck(deviceNum)
    }
    @IBAction func onWasher2Button(_ sender: AnyObject) {
        let deviceNum:Int = 2
        alarmCheck(deviceNum)
    }
    
    func alarmCheck(_ deviceNum:Int){
        // 세탁기는 푸쉬 알림
        if (deviceNum == 1 || deviceNum == 2) {
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
//                        print("response = \(response)")
                        let responseString = String(data: data!, encoding: String.Encoding.utf8)
                        print("responseString = \(responseString)")
                        DispatchQueue.main.async {
                            self.alertUser("알림 취소", body: "\(deviceNum)번 세탁기의 알림을 받지 않습니다.")
                        }
                        self.changeAlarmButton(deviceNum: deviceNum, status: 0)
                        self.alarmBool.set(0, forKey: "device\(deviceNum)")
                    }
                    task.resume()
                } else {
                    print("알림 받기")
                    let url = URL(string:"http://52.78.53.87/fcm/laundry.php")
                    var request = URLRequest(url: url!)
                    let bodydata = "num=\(deviceNum)&token=\(token)&device=ios"
                    
                    request.httpMethod = "POST"
                    request.httpBody = bodydata.data(using: String.Encoding.utf8)
                    
                    let task = URLSession.shared.dataTask(with: request as URLRequest) {
                        data, response, error in
                        if error != nil{
                            print("error = \(error)")
                            return
                        }
//                        print("response = \(response)")
                        let responseString = String(data: data!, encoding: String.Encoding.utf8)
                        print("responseString = \(responseString)")
                        DispatchQueue.main.async {
                            self.alertUser("알림 받기", body: "\(deviceNum)번 세탁기의 알림을 받습니다.")
                        }
                        self.changeAlarmButton(deviceNum: deviceNum, status: 1)
                        self.alarmBool.set(1, forKey: "device\(deviceNum)")
                    }
                    task.resume()
                }
            }
            task.resume()
        }
        
    }
    
    func getDeviceInfoFromServer() {
        
        let urlString = "http://52.78.53.87/timer/status.php"
        let url = URL(string: urlString)
        
        URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
            if error != nil {
                print(error as Any)
            } else {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                    
                    if let resultArray = parsedData["result"] as? [[String:Any]] {
                        let dicOfNum1 = resultArray[0]
                        let dicOfNum2 = resultArray[1]
                        let dicOfNum3 = resultArray[2]
                        let dicOfNum4 = resultArray[3]

                        guard let statusOfNum1 = dicOfNum1["status"] as? String,
                            let finishTimeOfNum1 = dicOfNum1["time"] as? String else {
                            print("1번 오류")
                            return
                        }
                        guard let statusOfNum2 = dicOfNum2["status"] as? String,
                            let finishTimeOfNum2 = dicOfNum2["time"] as? String else {
                            print("2번 오류")
                            return
                        }
                        guard let statusOfNum3 = dicOfNum3["status"] as? String else {
                            print("3번 오류")
                            return
                        }
                        guard let statusOfNum4 = dicOfNum4["status"] as? String else {
                            print("4번 오류")
                            return
                        }
                        
                        // Refresh 를 한번에
                        DispatchQueue.main.async {
                            self.refreshStatus(status1: statusOfNum1, finishTime1: finishTimeOfNum1, status2: statusOfNum2, finishTime2: finishTimeOfNum2, status3: statusOfNum3, status4: statusOfNum4)
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
    
    func changeEveryAlarmButton() {
        self.changeAlarmButton(deviceNum: 1, status: alarmBool.integer(forKey: "device1"))
        self.changeAlarmButton(deviceNum: 2, status: alarmBool.integer(forKey: "device2"))
    }
    func changeAlarmButton(deviceNum:Int, status:Int){
        if status == 0 {
            if (deviceNum == 1) {
                washer1Button.setTitle("알림받기", for: .normal)
                washer1Button.setTitleColor(UIColor(red: 0.85, green: 0.858, blue: 0.854, alpha: 1.0), for: .normal)
                washer1Button.setBackgroundImage(UIImage(named: "AlarmInactive.png"), for: .normal)
            } else if (deviceNum == 2) {
                washer2Button.setTitle("알림받기", for: .normal)
                washer2Button.setTitleColor(UIColor(red: 0.85, green: 0.858, blue: 0.854, alpha: 1.0), for: .normal)
                washer2Button.setBackgroundImage(UIImage(named: "AlarmInactive.png"), for: .normal)
            }
        } else {
            if (deviceNum == 1) {
                washer1Button.setTitle("알림취소", for: .normal)
                washer1Button.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
                washer1Button.setBackgroundImage(UIImage(named: "AlarmActive.png"), for: .normal)
            } else if (deviceNum == 2) {
                washer2Button.setTitle("알림취소", for: .normal)
                washer2Button.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
                washer2Button.setBackgroundImage(UIImage(named: "AlarmActive.png"), for: .normal)
            }
        }
    }
    
    // refreshing device status
    func refreshStatus(status1:String, finishTime1:String, status2:String, finishTime2:String ,status3:String, status4:String) {
        // Refresh Washer
        let currentDate = Date()
        if status1 == "0" {
            washer1NameLabel.textColor = UIColor(red: 0.85, green: 0.858, blue: 0.854, alpha: 1.0)
            washer1PercentLabel.textColor = UIColor(red: 0.364, green: 0.364, blue: 0.364, alpha: 1.0)
            washer1PercentLabel.text = "0%"
            washer1StatusLabel.text = "사용 가능"
            washer1StatusLabel.textColor = UIColor(red: 0.0, green: 0.537, blue: 0.874, alpha: 1.0)
            washer1Button.setTitle("알림받기", for: .normal)
            washer1Button.setTitleColor(UIColor(red: 0.85, green: 0.858, blue: 0.854, alpha: 1.0), for: .normal)
            washer1Button.setBackgroundImage(UIImage(named: "AlarmInactive.png"), for: .normal)
            washer1Button.isEnabled = false
        } else {
            guard let finishDate1 = DF.date(from: finishTime1) else {
                print("*** Getting finish date error")
                return
            }
            let intervalSeconds = finishDate1.timeIntervalSince(currentDate)
            
            let intervalPercent = Double(intervalSeconds/washerDuration)
            self.washer1ProgressBarView.progress = intervalPercent
            let percentProgress = round(self.washer1ProgressBarView.progress as Double * multiplier) / multiplier
            washer1PercentLabel.text = "\(NF.string(from: NSNumber(value: percentProgress))!)"
            let intervalMinutes = Int(intervalSeconds/60)
            washer1StatusLabel.text = "\(intervalMinutes)분"
            
            washer1NameLabel.textColor = UIColor(red: 0.364, green: 0.364, blue: 0.364, alpha: 1.0)
            washer1PercentLabel.textColor = UIColor(red: 0.0, green: 0.537, blue: 0.874, alpha: 1.0)
            washer1StatusLabel.textColor = UIColor(red: 0.364, green: 0.364, blue: 0.364, alpha: 1.0)
            washer1Button.isEnabled = true
        }
        
        if status2 == "0" {
            washer2NameLabel.textColor = UIColor(red: 0.85, green: 0.858, blue: 0.854, alpha: 1.0)
            washer2PercentLabel.textColor = UIColor(red: 0.364, green: 0.364, blue: 0.364, alpha: 1.0)
            washer2PercentLabel.text = "0%"
            washer2StatusLabel.text = "사용 가능"
            washer2StatusLabel.textColor = UIColor(red: 0.0, green: 0.537, blue: 0.874, alpha: 1.0)
            washer2Button.setTitle("알림받기", for: .normal)
            washer2Button.setTitleColor(UIColor(red: 0.85, green: 0.858, blue: 0.854, alpha: 1.0), for: .normal)
            washer2Button.setBackgroundImage(UIImage(named: "AlarmInactive.png"), for: .normal)
            washer2Button.isEnabled = false

        } else {
            guard let finishDate2 = DF.date(from: finishTime2) else {
                print("*** Getting finish date error")
                return
            }
            let intervalSeconds = finishDate2.timeIntervalSince(currentDate)
            let intervalPercent = Double(intervalSeconds/washerDuration)
            self.washer2ProgressBarView.progress = intervalPercent
            let percentProgress = round(self.washer2ProgressBarView.progress as Double * multiplier) / multiplier
            washer2PercentLabel.text = "\(NF.string(from: NSNumber(value: percentProgress))!)"
            let intervalMinutes = Int(intervalSeconds/60)
            washer2StatusLabel.text = "\(intervalMinutes)분"
            
            washer2NameLabel.textColor = UIColor(red: 0.364, green: 0.364, blue: 0.364, alpha: 1.0)
            washer2PercentLabel.textColor = UIColor(red: 0.0, green: 0.537, blue: 0.874, alpha: 1.0)
            washer2StatusLabel.textColor = UIColor(red: 0.364, green: 0.364, blue: 0.364, alpha: 1.0)
            washer2Button.isEnabled = true
        }
        // Refresh Dryer
        
        if status3 == "0" {
            self.dryer1ProgressBarView.progress = 0.0
            dryer1NameLabel.textColor = UIColor(red: 0.85, green: 0.858, blue: 0.854, alpha: 1.0)
            dryer1StatusLabel.text = "사용 가능"
            dryer1StatusLabel.textColor = UIColor(red: 0.0, green: 0.537, blue: 0.874, alpha: 1.0)

        } else {
            self.dryer1ProgressBarView.progress = 1.0
            dryer1NameLabel.textColor = UIColor(red: 0.364, green: 0.364, blue: 0.364, alpha: 1.0)
            dryer1StatusLabel.text = "사용 중"
            dryer1StatusLabel.textColor = UIColor(red: 0.364, green: 0.364, blue: 0.364, alpha: 1.0)
        }
        
        if status4 == "0" {
            self.dryer2ProgressBarView.progress = 0.0
            dryer2NameLabel.textColor = UIColor(red: 0.85, green: 0.858, blue: 0.854, alpha: 1.0)
            dryer2StatusLabel.text = "사용 가능"
            dryer2StatusLabel.textColor = UIColor(red: 0.0, green: 0.537, blue: 0.874, alpha: 1.0)

        } else {
            self.dryer2ProgressBarView.progress = 1.0
            dryer2NameLabel.textColor = UIColor(red: 0.364, green: 0.364, blue: 0.364, alpha: 1.0)
            dryer2StatusLabel.text = "사용 중"
            dryer2StatusLabel.textColor = UIColor(red: 0.364, green: 0.364, blue: 0.364, alpha: 1.0)
        }
    }
    
    
}

extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect (x: 0, y: 0, width: self.frame.height, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x:0, y:self.frame.height - thickness, width: UIScreen.main.bounds.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height)
            break
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        self.addSublayer(border)
    }
    
}
