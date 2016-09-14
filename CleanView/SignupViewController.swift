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
    
    @IBOutlet var newPhoneTextField: UITextField!
    
    // Text Field 아래에 가이드를 표시하는 Labels
    @IBOutlet var usernameDuplicatedLabel: UILabel!
    
    @IBOutlet var passwordNeededLabel: UILabel!
    
    @IBOutlet var passwordConfirmNeededLabel: UILabel!
    
    var activeTextField = UITextField()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.newUsernameTextField.delegate = self
        self.newPasswordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
        self.newPhoneTextField.delegate = self
        
        addCancelDoneButton()
        // Do any additional setup after loading the view.
        /*
        newUsernameTextField.delegate = self
        newPasswordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        newPhoneTextField.delegate = self
        */
    }

    override func viewDidAppear(animated: Bool) {
        self.newUsernameTextField.becomeFirstResponder()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // 키보드 이벤트를 View Controller에서 직접 처리
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField.isEqual(self.newUsernameTextField)){
            self.newPasswordTextField.becomeFirstResponder()
        }else if(textField.isEqual(self.newPasswordTextField)){
            self.confirmPasswordTextField.becomeFirstResponder()
        }else if(textField.isEqual(self.confirmPasswordTextField)){
            self.newPhoneTextField.becomeFirstResponder()
        }else if(textField.isEqual(self.newPhoneTextField)){
            self.view.endEditing(true)
        }
        return true
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.newUsernameTextField.resignFirstResponder()
        self.newPasswordTextField.resignFirstResponder()
        self.confirmPasswordTextField.resignFirstResponder()
        self.newPhoneTextField.resignFirstResponder()
    }
    // 유저에게 기본 알람을 보낼 수 있는 함수
    func alertUser(title:String, body:String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "확인", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: false, completion: nil)
    }
    
    // 회원 가입 제출 버튼
    @IBAction func onSignupButton(sender: AnyObject) {
        
        let id = newUsernameTextField.text
        let pw = newPasswordTextField.text
        let pwConfirm = confirmPasswordTextField.text
        let phone = newPhoneTextField.text
        
        if (id != "") {
            if (pw != "") {
                if (pwConfirm != "") {
                    if (pw == pwConfirm) {
                        postToServer(id!, password: pw!, phone: phone!)
                    }else {
                        alertUser("경고", body: "비밀번호를 재확인해주십시오.")
                    }
                }else{
                    alertUser("경고", body: "비밀번호 확인은 필수 입력사항입니다.")
                }
            }else{
                alertUser("경고", body: "비밀번호는 필수 입력사항입니다.")
            }
        }else{
            alertUser("경고", body: "아이디는 필수 입력사항입니다.")
        }
    }
    
    // 회원 가입 취소 버튼
    @IBAction func onCancelButton(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    // 서버로 통신
    func postToServer(username:String ,password:String ,phone:String){
        print("회원 가입 시도")
        
        let url : NSURL = NSURL(string: "http://52.78.53.87/ffff.php")!
        
        let request : NSMutableURLRequest = NSMutableURLRequest(URL: url)
        
        let bodydata = "id=\(username)&password=\(password)&phone=\(phone)"
        print("\(bodydata) 가 들어간당")
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
            if (responseString == "query error"){
                dispatch_async(dispatch_get_main_queue()){
                    self.alertUser("경고", body: "이미 존재하는 아이디입니다.")
                }
            } else {
                print("회원 가입")
                dispatch_async(dispatch_get_main_queue()){
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
        task.resume()
    }
    
    func addCancelDoneButton(){
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        
        let keyboardFlexBarButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let keyboardDoneBarButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action:"doneEditing")
        
        keyboardToolbar.items = [keyboardFlexBarButton,keyboardDoneBarButton]
        newUsernameTextField.inputAccessoryView = keyboardToolbar
        newPasswordTextField.inputAccessoryView = keyboardToolbar
        confirmPasswordTextField.inputAccessoryView = keyboardToolbar
        newPhoneTextField.inputAccessoryView = keyboardToolbar
    }
    // 현재 활성화 되어 있는 TextField
    func textFieldDidBeginEditing(textField: UITextField) {
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
