//
//  VisitorQRCodeView.swift
//  INIADFES-2019
//
//  Created by Kentaro on 2019/10/18.
//  Copyright © 2019 Kentaro. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import WebKit

class VisitorAttributeForm:UIView, WKNavigationDelegate, WKUIDelegate{
    var baseUrl = ""
    var apiKey = ""
    
    @IBOutlet weak var webView: WKWebView!
    
    func viewForm(){
        webView.load(URLRequest.init(url: URL(string:"\(baseUrl)/visitor/attribute/register?api_key=\(apiKey)")!))
        webView.navigationDelegate = self
        webView.uiDelegate = self
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        guard let url = navigationAction.request.url else{
            return
        }
        print(url.absoluteString)
        if url.scheme != "iniadfes"{
            decisionHandler(.allow, preferences)
            return
        }
        
        print(url.host)
        if url.host == "require-external-browser"{
            let parameter = url.queryParams()
            guard let goto = parameter["goto"] else{
                return
            }
            
            let redirectUrl = URL(string: goto)!
            UIApplication.shared.open(redirectUrl)
        }else{
            UIApplication.shared.open(url)
        }
        decisionHandler(.cancel,preferences)
    }
}

class VisitorQRCodeDisplay:UIView{
    
}

class QRCodeReader:UIView{
    
}
