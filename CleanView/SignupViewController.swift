//
//  SignupViewController.swift
//  CleanView
//
//  Created by Sanghoon Ahn on 2016. 8. 16..
//  Copyright © 2016년 AHN. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var newUsernameTextField: UITextField!
    
    @IBOutlet var newPasswordTextField: UITextField!
    
    @IBOutlet var confirmPasswordTextField: UITextField!
    
    @IBOutlet var navigationBar: UINavigationBar!
    
    var activeTextField = UITextField()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.barTintColor = UIColor(red: 0.0, green: 0.537, blue: 0.874, alpha: 1.0)
        self.navigationBar.barStyle = UIBarStyle.black
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationBar.tintColor = UIColor.white
        
        self.newUsernameTextField.delegate = self
        self.newPasswordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
        
        // 키보드에 버튼 추가
        addCancelDoneButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        self.newUsernameTextField.becomeFirstResponder()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // 키보드 이벤트를 View Controller에서 직접 처리
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.isEqual(self.newUsernameTextField)){
            self.newPasswordTextField.becomeFirstResponder()
        }else if(textField.isEqual(self.newPasswordTextField)){
            self.confirmPasswordTextField.becomeFirstResponder()
        }else if(textField.isEqual(self.confirmPasswordTextField)){
            self.view.endEditing(true)
        }
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.newUsernameTextField.resignFirstResponder()
        self.newPasswordTextField.resignFirstResponder()
        self.confirmPasswordTextField.resignFirstResponder()
    }
    // 유저에게 기본 알람을 보낼 수 있는 함수
    func alertUser(_ title:String, body:String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: false, completion: nil)
    }
    
    // 회원 가입 제출 버튼
    @IBAction func onSignupButton(_ sender: AnyObject) {
        
        let rawId = newUsernameTextField.text
        let rawPw = newPasswordTextField.text
        let pwConfirm = confirmPasswordTextField.text
        guard let id = rawId?.trimmingCharacters(in: NSCharacterSet.whitespaces) else {
            print("String trim error")
            return
        }
        guard let pw = rawPw?.trimmingCharacters(in: NSCharacterSet.whitespaces) else {
            print("String trim error")
            return
        }
        if (id != "") {
            if (id.characters.count >= 4 && id.characters.count <= 10){
                if (pw != "") {
                    if (pw.characters.count >= 4 && pw.characters.count <= 12){
                        if (pwConfirm != "") {
                            if (pw == pwConfirm) {
                                postToServer(id, password: pw)
                            }else {
                                alertUser("경고", body: "비밀번호를 재확인해주십시오.")
                            }
                        }else{
                            alertUser("경고", body: "비밀번호 확인은 필수 입력사항입니다.")
                        }
                    }else {
                        alertUser("경고", body: "비밀번호의 길이는 공백없이 4 이상 12 이하입니다.")
                    }
                }else{
                    alertUser("경고", body: "비밀번호는 필수 입력사항입니다.")
                }
            }else {
                alertUser("경고", body: "아이디의 길이는 공백없이 4 이상 10 이하입니다.")
            }
        }else{
            alertUser("경고", body: "아이디는 필수 입력사항입니다.")
        }
    }
    
    // 회원 가입 취소 버튼
    @IBAction func onCancelButton(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // 서버로 통신
    func postToServer(_ username:String ,password:String){
        //print("회원 가입 시도")
        
        let url : URL = URL(string: "http://52.78.53.87/join.php")!
        
        var request = URLRequest(url: url)
        
        let bodydata = "id=\(username)&password=\(password)"
        
        request.httpMethod = "POST"
        request.httpBody = bodydata.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            if error != nil{
                print("error = \(error)")
                return
            }
//            print("response = \(response)")
            
            let responseString = String(data: data!, encoding: String.Encoding.utf8)
            print("responseString = \(responseString)")
            if (responseString == "query error"){
                DispatchQueue.main.async{
                    self.alertUser("경고", body: "이미 존재하는 아이디입니다.")
                }
            } else {
                //print("회원 가입")
                DispatchQueue.main.async{
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            }
        }
        task.resume()
    }
    
    func addCancelDoneButton(){
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        
        let keyboardFlexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let keyboardDoneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action:#selector(SignupViewController.doneEditing))
        
        keyboardToolbar.items = [keyboardFlexBarButton,keyboardDoneBarButton]
        newUsernameTextField.inputAccessoryView = keyboardToolbar
        newPasswordTextField.inputAccessoryView = keyboardToolbar
        confirmPasswordTextField.inputAccessoryView = keyboardToolbar
    }
    // 현재 활성화 되어 있는 TextField
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    @IBAction func doneEditing() {
        self.view.endEditing(true)
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
