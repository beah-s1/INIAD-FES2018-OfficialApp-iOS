//
//  IniadMapViewController.swift
//  INIADFES-2019
//
//  Created by Kentaro on 2019/09/16.
//  Copyright © 2019 Kentaro. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess

class IniadMapViewController:UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var selectedFloor = 1
    
    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var exhibitsView: UITableView!
    @IBOutlet weak var floorBar: UINavigationBar!
    
    var keyStore:Keychain!
    let configuration = Configuration.init()
    
    var contents = [Content]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initContents()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func initContents(){
        self.keyStore = Keychain.init(service: configuration.forKey(key: "keychain_identifier"))
        Alamofire.request(
            "\(configuration.forKey(key: "base_url"))/api/v1/contents",
            method: .get,
            parameters: [
                "floor":"\(self.selectedFloor)"
            ],
            headers: [
                "Authorization":"Bearer \(self.keyStore["api_key"]!)"
        ]).responseJSON{response in
            guard let value = response.result.value else{
                //self.renewContents()
                return
            }
            if response.response?.statusCode != 200{
                return
            }
            
            self.contents = []
            self.exhibitsView.reloadData()
            
            let contentsDict = JSON(value)
            for content in contentsDict["objects"]{
                var newContent = Content()
                newContent.ucode = content.1["ucode"].stringValue
                newContent.title = content.1["title"].stringValue
                newContent.organizer = content.1["organizer"].stringValue
                newContent.description = content.1["description"].stringValue
                newContent.place = content.1["place"].stringValue
                
                self.contents.append(newContent)
            }
            
            print(self.contents)
            self.exhibitsView.delegate = self
            self.exhibitsView.dataSource = self
            self.exhibitsView.rowHeight = 140
            
            self.exhibitsView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "content") as! ExhibitViewCell
        
        cell.organizerName.text = self.contents[indexPath.row].organizer
        cell.roomNum.text = self.contents[indexPath.row].place
        cell.exhibitDescription.text = self.contents[indexPath.row].description
        
        //***DO SOMETHING
        
        return cell
    }
    
    @IBAction func swipeLeft(_ sender: Any) {
        print("Swipe to Left")
        //increment
        if self.selectedFloor < 5{
            self.selectedFloor += 1
            self.initContents()
        }
    }
    
    @IBAction func swipeRight(_ sender: Any) {
        print("Swipe to Right")
        //decrement
        if self.selectedFloor > 1{
            self.selectedFloor -= 1
            self.initContents()
        }
    }
    
}
