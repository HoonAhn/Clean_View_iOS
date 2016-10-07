//
//  ViewController.swift
//  CleanView
//
//  Created by Sanghoon Ahn on 2016. 8. 16..
//  Copyright © 2016년 AHN. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var UsernameTextField: UITextField!
    @IBOutlet var PasswordTextField: UITextField!
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signinButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.UsernameTextField.delegate = self
        self.PasswordTextField.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let autoLoginInfo = UserDefaults.standard
        if let autoLoginID = autoLoginInfo.string(forKey: "ID"){
            if let autoLoginPW = autoLoginInfo.string(forKey: "PW"){
                print("자동 로그인 가능")
                get(autoLoginID, password: autoLoginPW)
            }
        } else {
            self.UsernameTextField.becomeFirstResponder()
            let alarmBool = UserDefaults.standard
            alarmBool.set(0, forKey: "device1")
            alarmBool.set(0, forKey: "device2")
            alarmBool.set(0, forKey: "device3")
            alarmBool.set(0, forKey: "device4")
            
        }
    }
    
    func refreshView() {
        UsernameTextField.text = ""
        PasswordTextField.text = ""
    }
    
    func get(_ username:String, password:String){
        let url = URL(string:"http://52.78.53.87/login.php")
        var request = URLRequest(url: url!)
        let bodydata = "id=\(username)&password=\(password)"
        
        request.httpMethod = "POST"
        DispatchQueue.main.async{
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
                if (responseString == "invalidid"){
                    DispatchQueue.main.async{
                        self.alertUser("경고", body: "존재하지 않는 아이디입니다.")
                    }
                    
                } else if (responseString == "invalidpassword") {
                    DispatchQueue.main.async{
                        self.alertUser("경고", body: "비밀번호를 다시 입력해주십시오.")
                    }
                } else {
                    print("로그인 성공")
                    
                    let userLoginInfo = UserDefaults.standard
                    userLoginInfo.setValue(username, forKey: "ID")
                    userLoginInfo.setValue(password, forKey: "PW")
                    
                    print("저장된 유저 정보 : \(userLoginInfo)")
                    
                    if let mnc = self.storyboard?.instantiateViewController(withIdentifier: "MainNC") as? UINavigationController {
                        mnc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        DispatchQueue.main.async{
                            self.present(mnc, animated: true, completion: nil)
                            self.refreshView()
                        }
                    }
                }
            }
            task.resume()
        }

    }
    // 유저에게 기본 알람을 보낼 수 있는 함수
    func alertUser(_ title:String, body:String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: false, completion: nil)
    }
    

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.isEqual(self.UsernameTextField)){
            self.PasswordTextField.becomeFirstResponder()
        } else if (textField.isEqual(self.PasswordTextField)){
            self.view.endEditing(true)
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.UsernameTextField.resignFirstResponder()
        self.PasswordTextField.resignFirstResponder()
    }
    // 로그인 버튼
    @IBAction func onLoginButton(_ sender: AnyObject) {
        
        let id = UsernameTextField.text
        let pw = PasswordTextField.text
        
        print("아이디 : \(id) 비밀번호 : \(pw)")
        
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
    @IBAction func onSignupButton(_ sender: AnyObject) {
        if let signupVC = self.storyboard?.instantiateViewController(withIdentifier: "SignupVC"){
            signupVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            self.present(signupVC, animated: true, completion: nil)
        }
    }

}

