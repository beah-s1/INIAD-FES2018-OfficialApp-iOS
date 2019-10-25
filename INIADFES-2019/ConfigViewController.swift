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
    @IBOutlet weak var content: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.keyStore = Keychain.init(service: configuration.forKey(key: "keychain_iden tifier"))
        
        guard let view = UINib(nibName: "OthersView", bundle: Bundle.main).instantiate(withOwner: self, options: nil).first as? OthersView else{
            return
        }
        
        if #available(iOS 13.0, *){
            view.backgroundColor = .systemBackground
        }
        view.logoImage.backgroundColor = .none
        view.frame.size.width = self.content.bounds.maxX
        self.content.contentSize.height = view.frame.size.height
        self.content.sizeToFit()
        
        self.content.addSubview(view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func openLegalInformation(){
        guard let view = storyboard!.instantiateViewController(withIdentifier: "Copyright") as? CopyrightViewController else{
            return
        }
        
        
        self.present(view, animated: true, completion: nil)
    }
    
    func openManual(){
        
    }
    
    func openPrivacyPolicy(){
        
    }
}

class CopyrightViewController:UIViewController{
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

class OthersView:UIView{
    @IBOutlet weak var logoImage: UIImageView!
    
    @IBAction func JumpToOfficialWebSite(_ sender: Any) {
        UIApplication.shared.open(URL(string:"https://iniadfes.com")!)
    }
    
    @IBAction func JumpToOfficialTwitter(_ sender: Any) {
        UIApplication.shared.open(URL(string:"https://twitter.com/iniadfeskoho")!)
    }
    
    @IBAction func JumpToOfficlalInstagram(_ sender: Any) {
        UIApplication.shared.open(URL(string:"https://www.instagram.com/iniad_fes/")!)
    }
    
    @IBAction func Legal(_ sender: Any) {
        let parentViewController = self.parentViewController() as! ConfigViewController
        parentViewController.openLegalInformation()
    }
    
    @IBAction func Manual(_ sender: Any) {
    }
    
    @IBAction func PrivacyPolicy(_ sender: Any) {
    }
}
