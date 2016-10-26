//
//  NoticeContentViewController.swift
//  CleanView
//
//  Created by Sanghoon Ahn on 2016. 10. 25..
//  Copyright © 2016년 AHN. All rights reserved.
//

import UIKit

class NoticeContentViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var contentTextView: UITextView!
    
    var dictionaryOfNotice = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        titleLabel.text = dictionaryOfNotice["title"]
        contentTextView.text = dictionaryOfNotice["content"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
