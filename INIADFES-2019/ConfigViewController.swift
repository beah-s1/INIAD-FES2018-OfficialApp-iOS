//
//  ConfigViewController.swift
//  INIADFES-2019
//
//  Created by Kentaro on 2019/10/21.
//  Copyright © 2019 Kentaro. All rights reserved.
//
//-------------------------//
//  仮で作っています、後からちゃんとしたConfigに直します
//

import Foundation
import UIKit
import KeychainAccess
import Alamofire
import SwiftyJSON

class ConfigViewController:UIViewController{
    let configuration = Configuration.init()
    var keyStore:Keychain!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.keyStore = Keychain.init(service: configuration.forKey(key: "keychain_identifier"))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func keyReset(_ sender: Any) {
        //APIキーのリセット
        try! self.keyStore.removeAll()
        exit(0)
    }
    
}
