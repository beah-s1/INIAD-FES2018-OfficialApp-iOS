//
//  VisitorQRCodeController.swift
//  INIADFES-2019
//
//  Created by Kentaro on 2019/10/07.
//  Copyright © 2019 Kentaro. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess

class VisitorQRCodeController:UIViewController{
    let configuration = Configuration.init()
    var keyStore:Keychain!
    var mode = 0 // 0 -> Visitor Mode(not registered attribute)/ 1 -> Visitor Mode(registered attribute)/ 2 -> student mode/ 3 -> admin mode
    
    @IBOutlet weak var userSubView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = false
        loadPermission()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func loadPermission(){
        self.keyStore = Keychain.init(service: configuration.forKey(key: "keychain_identifier"))
        
        Alamofire.request("\(configuration.forKey(key: "base_url"))/api/v1/user", method: .get, headers: ["Authorization": "Bearer \(self.keyStore["api_key"]!)"]).responseJSON{ response in
            guard let value = response.result.value else{
                return
            }
            
            let responseJsonObject = JSON(value)
            
            guard let appUserRole = responseJsonObject["role"].arrayObject as? [String] else{
                return
            }
            
            for layer in self.userSubView.subviews{
                //既に表示されているレイヤーは削除する
                layer.removeFromSuperview()
            }
            
            switch appUserRole{
            case (let role) where role.contains("circle_participant") || role.contains("fes_admin"):
                // QR読み取り画面
                break
            case (let role) where role.contains("visitor"):
                // QR表示画面
                guard let view = UINib(nibName: "VisitorQRCodeDisplay", bundle: Bundle.main).instantiate(withOwner: self, options: nil).first as? VisitorQRCodeDisplay else{
                    break
                }
                
                var visitorResponseObject:JSON!
                
                let semaphore = DispatchSemaphore(value: 0)
                let queue     = DispatchQueue.global(qos: .utility)
                Alamofire.request("\(self.configuration.forKey(key: "base_url"))/api/v1/visitor", method: .get, headers: ["Authorization": "Bearer \(self.keyStore["api_key"]!)"]).responseJSON(queue: queue, completionHandler: {response in
                    visitorResponseObject = JSON(response.result.value!)
                    
                    semaphore.signal()
                })
                semaphore.wait()
                
                print(visitorResponseObject)
                view.backgroundColor = .white
                view.displayQrCode(text: "https://app.iniadfes.com/visitor?user_id=\(visitorResponseObject["user_id"].stringValue)")
                self.userSubView.addSubview(view)
                
                break
            default:
                // 属性登録フォーム
                guard let view = UINib(nibName: "VisitorAttributeForm", bundle: Bundle.main).instantiate(withOwner: self, options: nil).first as? VisitorAttributeForm else{
                    break
                }
                view.backgroundColor = .systemBackground
                view.apiKey = self.keyStore["api_key"]!
                view.baseUrl = self.configuration.forKey(key: "base_url")
                view.viewForm()
                view.frame = self.userSubView.bounds
                
                self.userSubView.addSubview(view)
                
                break
            }
        }
    }
}
