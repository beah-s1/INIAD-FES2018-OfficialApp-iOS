//
//  ConfigViewController.swift
//  INIADFES-2019
//
//  Created by Kentaro on 2019/10/21.
//  Copyright © 2019 Kentaro. All rights reserved.
//
//

import Foundation
import UIKit
import KeychainAccess
import Alamofire
import SwiftyJSON
import WebKit

class ConfigViewController:UIViewController,UINavigationBarDelegate{
    let configuration = Configuration.init()
    var keyStore:Keychain!
    @IBOutlet weak var content: UIScrollView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.delegate = self
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
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        // ステータスバーの文字色を白で指定
        return UIStatusBarStyle.lightContent
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
        guard let view = storyboard!.instantiateViewController(withIdentifier: "OthersWebView") as? OthersWebViewController else{
            return
        }
        
        view.url = URL(string: "\(self.configuration.forKey(key: "base_url"))/manual?device_type=iOS")!
        self.present(view, animated: true, completion: nil)
        
    }
    
    func openPrivacyPolicy(){
        guard let view = storyboard!.instantiateViewController(withIdentifier: "OthersWebView") as? OthersWebViewController else{
            return
        }
        
        view.url = URL(string: "\(self.configuration.forKey(key: "base_url"))/privacy")!
        self.present(view, animated: true, completion: nil)
    }
}

class CopyrightViewController:UIViewController{
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

class OthersWebViewController:UIViewController,WKNavigationDelegate,WKUIDelegate{
    @IBOutlet weak var webView: WKWebView!
    var url:URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.load(URLRequest(url: url))
    }
    
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
        let parentViewController = self.parentViewController() as! ConfigViewController
        parentViewController.openManual()
    }
    
    @IBAction func PrivacyPolicy(_ sender: Any) {
        let parentViewController = self.parentViewController() as! ConfigViewController
        parentViewController.openPrivacyPolicy()
    }
}
