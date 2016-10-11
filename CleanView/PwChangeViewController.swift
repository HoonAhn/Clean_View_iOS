//
//  PwChangeViewController.swift
//  CleanView
//
//  Created by Sanghoon Ahn on 2016. 10. 11..
//  Copyright © 2016년 AHN. All rights reserved.
//

import UIKit

class PwChangeViewController: UIViewController {

    @IBOutlet var currentPWTextField: UITextField!
    @IBOutlet var newPWTextField: UITextField!
    @IBOutlet var newPWConfirmTestField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSaveBarButton(_ sender: AnyObject) {
    }
    
    @IBAction func onCancelBarButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
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
