//
//  ViewController.swift
//  CleanView
//
//  Created by Sanghoon Ahn on 2016. 8. 16..
//  Copyright © 2016년 AHN. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var LogoImageView: UIImageView!
    
    @IBOutlet var UsernameTextField: UITextField!
    
    @IBOutlet var PasswordTextField: UITextField!
    
    @IBOutlet var autoLoginSwitch: UISwitch!
    
    func refreshView() {
        UsernameTextField.text = ""
        PasswordTextField.text = ""
    }
    
    func get(username:String, password:String){
        let url = NSURL(string:"http://52.78.53.87/login.php")
        let request : NSMutableURLRequest = NSMutableURLRequest(URL: url!)
        let bodydata = "id=\(username)&password=\(password)"
        
        request.HTTPMethod = "POST"
        dispatch_async(dispatch_get_main_queue()){
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
                if (responseString == "invalidid"){
                    dispatch_async(dispatch_get_main_queue()){
                        self.alertUser("경고", body: "존재하지 않는 아이디입니다.")
                    }
                    
                } else if (responseString == "invalidpassword") {
                    dispatch_async(dispatch_get_main_queue()){
                        self.alertUser("경고", body: "비밀번호를 다시 입력해주십시오.")
                    }
                } else {
                    print("로그인 성공")
                    
                    if (self.autoLoginSwitch.on){
                        let userLoginInfo = NSUserDefaults.standardUserDefaults()
                        userLoginInfo.setValue(username, forKey: "ID")
                        userLoginInfo.setValue(password, forKey: "PW")
                        
                        print("저장된 유저 정보 : \(userLoginInfo)")
                    }
                    
                    if let mnc = self.storyboard?.instantiateViewControllerWithIdentifier("MainNC") as? UINavigationController {
                        mnc.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
                        dispatch_async(dispatch_get_main_queue()){
                            self.presentViewController(mnc, animated: true, completion: nil)
                            self.refreshView()
                        }
                    }
                }
            }
            task.resume()
        }

    }
    // 유저에게 기본 알람을 보낼 수 있는 함수
    func alertUser(title:String, body:String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "확인", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.UsernameTextField.delegate = self
        self.PasswordTextField.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
        // 이미지 불러오기
        /*
        if let path = NSBundle.mainBundle().pathForResource("CleanViewLogo", ofType:"jpeg") {
            LogoImageView.image = UIImage(named: path)
        }
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        let autoLoginInfo = NSUserDefaults.standardUserDefaults()
        if let autoLoginID = autoLoginInfo.stringForKey("ID"){
            if let autoLoginPW = autoLoginInfo.stringForKey("PW"){
                print("자동 로그인 가능")
                get(autoLoginID, password: autoLoginPW)
            }
        }
        self.UsernameTextField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField.isEqual(self.UsernameTextField)){
            self.PasswordTextField.becomeFirstResponder()
        } else if (textField.isEqual(self.PasswordTextField)){
            self.view.endEditing(true)
        }
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.UsernameTextField.resignFirstResponder()
        self.PasswordTextField.resignFirstResponder()
    }
    // 로그인 버튼
    @IBAction func onLoginButton(sender: AnyObject) {
        
        let id = UsernameTextField.text
        let pw = PasswordTextField.text
        
        print("아이디 : \(id) 비밀번호 : \(pw)")
        print("자동 로그인 여부 : \(autoLoginSwitch.on)")
        
        if (id != "") {
            if (pw != "") {
                get(id!, password: pw!)
            } else {
                alertUser("경고", body: "비밀번호를 입력해주십시오.")
                return
            }
        } else {
            alertUser("경고", body: "아이디를 입력해주십시오.")
            return
        }
    }
    
    // 회원 가입 버튼
    @IBAction func onSignupButton(sender: AnyObject) {
        if let signupVC = self.storyboard?.instantiateViewControllerWithIdentifier("SignupVC"){
            signupVC.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
            self.presentViewController(signupVC, animated: true, completion: nil)
        }
    }

}

