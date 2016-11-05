//
//  NoticeTableViewController.swift
//  CleanView
//
//  Created by Sanghoon Ahn on 2016. 10. 22..
//  Copyright © 2016년 AHN. All rights reserved.
//

import UIKit

class NoticeTableViewController: UITableViewController {

    var NoticeDictionary = [[String:String]]()
    let DF = DateFormatter()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var fullIndex : Int = -1
    var selectedRow : Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //hh:mm:ss
        DF.dateFormat = "yyyy-MM-dd"
        DF.locale = Locale(identifier: "ko_KR")
        DF.timeZone = TimeZone(identifier: "KST")
        
        activityIndicator.isHidden = true
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)

//        activityIndicator.isHidden = false
//        activityIndicator.startAnimating()
        
//        DispatchQueue.main.async {
//            
//        }
        self.getNoticeFromSever()
//        while(!activityIndicator.isHidden){
//            print("waiting for notcie dictionary to be filled......")
//        }
        
        //날짜대로 정렬이 필요하다면
        /*
        let orderedNoticeDictionary = NoticeDictionary?.sorted(by: {dic1, dic2 in
            dic1.["date"]
        })
        */
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    /*
    override func viewWillAppear(_ animated: Bool) {
        self.getNoticeFromSever()
    }
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.NoticeDictionary.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeCell", for: indexPath)
        fullIndex = self.NoticeDictionary.count
        let row = indexPath.row
        let notice = self.NoticeDictionary[fullIndex - row - 1]
        cell.textLabel?.text = notice["title"] as String!
        cell.detailTextLabel?.text = notice["date"] as String!
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func getNoticeFromSever(){
        let urlString = "http://52.78.53.87/notice.php"
        guard let url = URL(string: urlString) else {
            print("URL error")
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) {(data, response, error) in
            if error != nil {
                print(error!)
            } else {
                do {
                    
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                    
                    if let resultArray = parsedData["result"] as? [[String:Any]] {
                        //print("result Array is \(resultArray)")
                        for noticeDic in resultArray {
                            //print("appending!... : \(noticeDic)")
                            self.NoticeDictionary.append(noticeDic as! [String : String])
                        }
                    } else {
                        print("result를 JSON에서 파싱하는데서 오류")
                    }
                } catch {
                    print("*****JSON Parsing Error Occur!!*****")
                }
                
            }
            self.tableRefresh()
        }.resume()
        
    }
    
    func tableRefresh(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "noticeToContentSegue" {
            if let destination = segue.destination as? NoticeContentViewController,
                let selectedIndex = self.tableView.indexPathForSelectedRow?.row {
                destination.dictionaryOfNotice = self.NoticeDictionary[self.fullIndex - selectedIndex - 1]
                
                
            }
        }
    }
    // noticeToContentSegue

}





















