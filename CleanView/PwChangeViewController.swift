//
//  PwChangeViewController.swift
//  CleanView
//
//  Created by Sanghoon Ahn on 2016. 10. 11..
//  Copyright © 2016년 AHN. All rights reserved.
//

import UIKit

class PwChangeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var currentPWTextField: UITextField!
    
    @IBOutlet var newPWTextField: UITextField!
    
    @IBOutlet var newPWConfirmTextField: UITextField!
    
    @IBOutlet var navigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
         let statWindow = UIApplication.shared.value(forKey:"statusBarWindow") as! UIView
         let statusBar = statWindow.subviews[0] as UIView
         statusBar.backgroundColor = UIColor(red: 0.0, green: 0.537, blue: 0.874, alpha: 1.0)
         */

        self.navigationBar.barTintColor = UIColor(red: 0.0, green: 0.537, blue: 0.874, alpha: 1.0)
        self.navigationBar.barStyle = UIBarStyle.black
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationBar.tintColor = UIColor.white
        
        self.currentPWTextField.delegate = self
        self.newPWTextField.delegate = self
        self.newPWConfirmTextField.delegate = self
        
        addCancelDoneButton()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 키보드 이벤트를 View Controller에서 직접 처리
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.isEqual(self.currentPWTextField)){
            self.newPWTextField.becomeFirstResponder()
        }else if(textField.isEqual(self.newPWTextField)){
            self.newPWConfirmTextField.becomeFirstResponder()
        }else if(textField.isEqual(self.newPWConfirmTextField)){
            self.view.endEditing(true)
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.currentPWTextField.resignFirstResponder()
        self.newPWTextField.resignFirstResponder()
        self.newPWConfirmTextField.resignFirstResponder()
    }
    
    // 유저에게 기본 알람을 보낼 수 있는 함수
    func alertUser(_ title:String, body:String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: false, completion: nil)
    }
    
    func postToServer(id : String, newPassword : String) {
        
        let url : URL = URL(string: "http://52.78.53.87/change.php")!
        
        var request = URLRequest(url: url)
        
        let bodydata = "id=\(id)&password=\(newPassword)"
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
                print("query error")
            } else {
                let autoLoginInfo = UserDefaults.standard
                autoLoginInfo.set(newPassword, forKey: "PW")
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
        let keyboardDoneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action:#selector(PwChangeViewController.doneEditing))
        
        keyboardToolbar.items = [keyboardFlexBarButton,keyboardDoneBarButton]
        currentPWTextField.inputAccessoryView = keyboardToolbar
        newPWTextField.inputAccessoryView = keyboardToolbar
        newPWConfirmTextField.inputAccessoryView = keyboardToolbar
    }
    
    @IBAction func onSaveBarButton(_ sender: AnyObject) {
        
        let currentPW = currentPWTextField.text
        let newRawPW = newPWTextField.text
        let confirmPW = newPWConfirmTextField.text
        
        let autoLoginInfo = UserDefaults.standard
        guard let username = autoLoginInfo.string(forKey: "ID") else{
            print("ID getting error")
            return
        }
        guard let password = autoLoginInfo.string(forKey: "PW") else{
            print("PW getting error")
            return
        }
        
        guard let pw = newRawPW?.trimmingCharacters(in: NSCharacterSet.whitespaces) else {
            print("String trim error")
            return
        }
        
        if (currentPW != "" && currentPW == password) {
            if (pw != "") {
                if (pw.characters.count >= 4 && pw.characters.count <= 12){
                    if (confirmPW != "") {
                        if (pw == confirmPW) {
                            postToServer(id: username, newPassword : pw)
                        } else {
                            alertUser("경고", body: "비밀번호를 재확인해주십시오.")
                        }
                    } else{
                        alertUser("경고", body: "비밀번호 확인은 필수 입력사항입니다.")
                    }
                } else {
                    alertUser("경고", body: "비밀번호의 길이는 공백없이 4 이상 12 이하입니다.")
                }
            } else{
                alertUser("경고", body: "비밀번호는 필수 입력사항입니다.")
            }
        } else{
            alertUser("경고", body: "현재 비밀번호는 필수 입력사항입니다.")
        }

    }
    
    @IBAction func onCancelBarButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func doneEditing() {
        self.view.endEditing(true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
