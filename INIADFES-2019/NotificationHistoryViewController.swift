//
//  NotificationHistoryViewController.swift
//  INIADFES-2019
//
//  Created by Kentaro on 2019/10/26.
//  Copyright © 2019 Kentaro. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess

class NotificationHistoryViewController:UIViewController,UITableViewDelegate,UITableViewDataSource,UINavigationBarDelegate{
    @IBOutlet weak var navBar: UINavigationBar!
    var keyStore:Keychain!
    var conf = Configuration()
    var notifications = [[String:String]]()
    @IBOutlet weak var notificationTable: UITableView!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.keyStore = Keychain.init(service: conf.forKey(key: "keychain_identifier"))
        
        navBar.delegate = self
        
        Alamofire.request("\(conf.forKey(key: "base_url"))/api/v1/notifications", method: .get, headers: ["Authorization":"Bearer \(self.keyStore["api_key"]!)"]).responseJSON{response in
            guard let value = response.result.value else{
                return
            }
            
            let notificationJsonObject = JSON(value)
            print(notificationJsonObject)
            for i in notificationJsonObject["objects"]{
                self.notifications.append(["id":i.1["id"].stringValue,"title":i.1["title"].stringValue,"message":i.1["message"].stringValue])
            }
            
            self.notificationTable.reloadData()
        }
        
        self.notificationTable.delegate = self
        self.notificationTable.dataSource = self
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        // ステータスバーの文字色を白で指定
        return UIStatusBarStyle.lightContent
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(self.notifications[indexPath.row]["id"]!)  \(self.notifications[indexPath.row]["title"]!)"
        
        cell.accessoryType = .detailButton
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alert = UIAlertController(title: self.notifications[indexPath.row]["title"], message: self.notifications[indexPath.row]["message"], preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
}
