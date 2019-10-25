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
    
    var cachedImages = [String:UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initContents()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func initContents(){
        if self.selectedFloor != 5{
            self.floorBar.topItem?.title = "\(self.selectedFloor)F MAP"
        }else{
            self.floorBar.topItem?.title = "七福神広場 MAP"
        }
        
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
                newContent.organizer = content.1["organizer"]["organizer_name"].stringValue
                newContent.description = content.1["description"].stringValue
                newContent.imageUrl = content.1["image"].stringValue
                
                var room = Room()
                for doorName in content.1["place"]["door_name"]{
                    room.doorNames.append(doorName.1.stringValue)
                }
                if room.doorNames.count == 0{
                    room.doorNames.append("なし")
                }
                
                room.ucode = content.1["place"]["ucode"].stringValue
                room.roomColorCode = content.1["place"]["room_color"].stringValue
                room.roomName = content.1["place"]["room_name"].stringValue
                
                newContent.place = room
                
                self.contents.append(newContent)
            }
            
            //print(self.contents)
            self.exhibitsView.delegate = self
            self.exhibitsView.dataSource = self
            self.exhibitsView.rowHeight = 140
            
            self.exhibitsView.reloadData()
            
            switch self.selectedFloor{
            case 1:
                self.mapImage.image = UIImage.init(named: "1F")
            case 2:
                self.mapImage.image = nil
            case 3:
                self.mapImage.image = UIImage.init(named: "3F")
            case 4:
                self.mapImage.image = UIImage.init(named: "4F")
            case 5:
                self.mapImage.image = UIImage.init(named: "5F")
            default:break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "content") as! ExhibitViewCell
        
        cell.organizerName.text = self.contents[indexPath.row].title
        cell.roomNum.text = "\(self.contents[indexPath.row].place.roomName) 扉番号：\(self.contents[indexPath.row].place.doorNames.joined(separator: ","))"
        cell.exhibitDescription.text = self.contents[indexPath.row].description
        if let image = self.cachedImages[self.contents[indexPath.row].imageUrl]{
            cell.exhibitImage.image = image
        }else{
            Alamofire.request(self.contents[indexPath.row].imageUrl).responseData{response in
                guard let value = response.result.value else{
                    return
                }
                let image = UIImage.init(data: value)
                
                self.cachedImages[self.contents[indexPath.row].imageUrl] = image
                cell.exhibitImage.image = image
            }
        }
        
        if self.contents[indexPath.row].place.roomColorCode != ""{
            cell.roomColor.image = UIImage.image(color: UIColor(hex: self.contents[indexPath.row].place.roomColorCode), size: CGSize.init(width: 1000, height: 1000))
        }else{
            cell.roomColor.image = UIImage.image(color: UIColor(hex: "#FFFFFF",alpha: 0.0), size: CGSize.init(width: 1000, height: 1000))
        }
        
        return cell
    }
    
    @IBAction func swipeLeft(_ sender: Any) {
        //print("Swipe to Left")
        //increment
        if self.selectedFloor >= 5{
            return
        }
        
        self.selectedFloor += 1
        if self.selectedFloor == 2{
            self.selectedFloor += 1
        }
        self.initContents()
    }
    
    @IBAction func swipeRight(_ sender: Any) {
        //print("Swipe to Right")
        //decrement
        if self.selectedFloor <= 1{
            return
        }
        
        self.selectedFloor -= 1
        if self.selectedFloor == 2{
            self.selectedFloor -= 1
        }
        self.initContents()
    }
    
    @IBAction func touchImage(_ sender: Any){
        let view = storyboard!.instantiateViewController(withIdentifier: "iniadMapExpansionView") as! IniadMapExpansionViewController
        view.baseImage = self.mapImage.image
        self.present(view, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let _ = tableView.cellForRow(at: indexPath) as? ExhibitViewCell else{
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        let view = storyboard!.instantiateViewController(withIdentifier: "contentDescriptionView") as! ContentDescriptionViewController
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.present(view, animated: true, completion: nil)
        
        view.contentTitleText.text = self.contents[indexPath.row].title
        view.roomAndOrganizationText.text = "\(self.contents[indexPath.row].place.roomName)/\(self.contents[indexPath.row].organizer)"
        view.contentDescriptionText.text = self.contents[indexPath.row].description
        view.contentImageView.image = self.cachedImages[self.contents[indexPath.row].imageUrl]
    }
}
