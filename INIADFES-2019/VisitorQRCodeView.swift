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
    //アプリ内からユーザーの属性を登録する画面
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
    //属性登録を済ませたユーザーがQRコードを表示する画面
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
    var baseUrl = ""
    var apiKey = ""
    
    @IBOutlet weak var qrCam: UIView!
    let session = AVCaptureSession()
    var cameraMode = 0 //0・・・外カメラ、1・・・内カメラ
    @IBOutlet weak var statusText: UILabel!
    var availableCircles = [[String:String]]()
    var selectedCircle = [String:String]()
    @IBOutlet weak var selectedCircleText: UILabel!
    
    func initialize(){
        self.selectedCircleText.text = self.selectedCircle["name"]
        
        self.session.stopRunning()
        for input in self.session.inputs{
            self.session.removeInput(input)
        }
        for output in self.session.outputs{
            self.session.removeOutput(output)
        }
        self.qrCam.layer.sublayers?.removeAll()
        
        var discoverSession:AVCaptureDevice.DiscoverySession!  //選択されているモードにあわせて切り替え
        if self.cameraMode == 0{
            discoverSession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: AVCaptureDevice.Position.back)
        }else{
            discoverSession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: AVCaptureDevice.Position.front)
        }
        
        let devices = discoverSession.devices
        if let cameraDevice = devices.first{
            do{
                //カメラ入力設定
                let deviceInput = try AVCaptureDeviceInput(device: cameraDevice)
                
                if !self.session.canAddInput(deviceInput){
                }
                self.session.addInput(deviceInput)
                
                //ディスプレイ設定
                let output = AVCaptureMetadataOutput()
                if self.session.canAddOutput(output){
                    self.session.addOutput(output)
                }
                
                
                output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                output.metadataObjectTypes = [.qr]
                

                self.qrCam.clipsToBounds = true
                let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                previewLayer.frame = self.qrCam.frame
                previewLayer.videoGravity = .resizeAspectFill
                
                self.qrCam.layer.addSublayer(previewLayer)
                
                self.session.startRunning()
            }catch{
                
            }
        }
        
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject]{
            if metadata.type != .qr {continue}
            if metadata.stringValue == nil {continue}
            
            guard let url = URL(string: metadata.stringValue!) else{
                continue
            }
            
            if url.host != "app.iniadfes.com" || url.path != "/visitor"{
                return
            }
            
            guard let userId = url.queryParams()["user_id"] else{
                return
            }
            self.statusText.text = "処理中です..."
            self.session.stopRunning()
            
            Alamofire.request("\(baseUrl)/api/v1/visitor/entry/\(self.selectedCircle["ucode"]!)", method: .post,parameters: ["user_id":userId], headers: ["Authorization":"Bearer \(apiKey)"]).responseJSON{response in
                print(JSON(response.result.value!))
                if response.response?.statusCode != 200{
                    self.statusText.text = "登録できませんでした"
                }else{
                    self.statusText.text = "登録完了"
                }

                Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: {_ in
                    self.statusText.text = "読み取り中..."
                    self.session.startRunning()
                })
                
            }
            break
        }
    }
    
    @IBAction func changeCameraPosition(_ sender: Any) {
        if self.cameraMode == 0{
            self.cameraMode = 1
        }else{
            self.cameraMode = 0
        }
        
        self.initialize()
    }
    
    @IBAction func changeCircleButton(_ sender: Any) {
        for i in 0...self.availableCircles.count-1{
            if self.availableCircles[i]["ucode"] != self.selectedCircle["ucode"]{
                continue
            }
            
            if i == self.availableCircles.count-1{
                self.selectedCircle = self.availableCircles[0]
            }else{
                self.selectedCircle = self.availableCircles[i+1]
            }
            
            self.selectedCircleText.text = self.selectedCircle["name"]
            break
        }
    }
}
