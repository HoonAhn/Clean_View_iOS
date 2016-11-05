//
//  SettingTableViewController.swift
//  CleanView
//
//  Created by Sanghoon Ahn on 2016. 10. 11..
//  Copyright © 2016년 AHN. All rights reserved.
//

import UIKit
import Firebase

class SettingTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = indexPath.section
        let row = indexPath.row
        print("Section: \(section)")
        print("Row: \(row)")

        if (section == 1 && row == 1) {
            print("로그아웃 되었습니다.")
            let autoLoginInfo = UserDefaults.standard
            if autoLoginInfo.string(forKey: "ID") != nil{
                autoLoginInfo.removeObject(forKey: "ID")
                autoLoginInfo.removeObject(forKey: "PW")
            }
            removeAlarms()
            
            var vc = self.presentingViewController
            while ((vc?.presentingViewController) != nil) {
                vc = vc?.presentingViewController
            }
            vc?.dismiss(animated: true, completion: nil)
        }
    }
    
    func removeAlarms() {
        let token = FIRInstanceID.instanceID().token()!
        
        for index in 1...2 {
            let url = URL(string:"http://52.78.53.87/fcm/confirm.php")
            var request = URLRequest(url: url!)
            let bodydata = "num=\(index)&token=\(token)"
            
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
                    
                    let url = URL(string:"http://52.78.53.87/fcm/delete.php")
                    var request = URLRequest(url: url!)
                    let bodydata = "num=\(index)&token=\(token)"
                    
                    request.httpMethod = "POST"
                    request.httpBody = bodydata.data(using: String.Encoding.utf8)
                    
                    let task = URLSession.shared.dataTask(with: request as URLRequest) {
                        data, response, error in
                        if error != nil{
                            print("error = \(error)")
                            return
                        }
                    }
                    task.resume()
                }
            }
            task.resume()
        }
    }
    /*
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
