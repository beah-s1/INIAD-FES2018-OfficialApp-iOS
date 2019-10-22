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
import AVFoundation

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
    @IBOutlet weak var qrCodeView: UIImageView!
    
    func displayQrCode(text:String){
        let data = text.data(using: String.Encoding.utf8)!
        
        let qr = CIFilter(name: "CIQRCodeGenerator", parameters: ["inputMessage": data, "inputCorrectionLevel": "M"])!
        let sizeTransform = CGAffineTransform(scaleX: 255, y: 255)
        let qrImage = qr.outputImage!.transformed(by: sizeTransform)
        let context = CIContext()
        let cgImage = context.createCGImage(qrImage, from: qrImage.extent)
        let uiImage = UIImage(cgImage: cgImage!)
        
        qrCodeView.contentMode = .scaleAspectFill
        qrCodeView.image = uiImage
    }
}

class QRCodeReader:UIView, AVCaptureMetadataOutputObjectsDelegate{
    @IBOutlet weak var qrCam: UIView!
    let session = AVCaptureSession()
    let cameraMode = 0 //0・・・外カメラ、1・・・内カメラ
    
    func initialize(){
        
    }
}
