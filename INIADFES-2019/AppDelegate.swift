//
//  AppDelegate.swift
//  INIADFES-2019
//
//  Created by Kentaro on 2019/09/16.
//  Copyright © 2019 Kentaro. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        checkApiKey()
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0,*)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0,*)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func checkApiKey(){
        let config = Configuration()
        let keyStore = Keychain.init(service: config.forKey(key: "keychain_identifier"))
        if keyStore["api_key"] != nil{
            return
        }else{
            let semaphore = DispatchSemaphore(value: 0)
            let queue     = DispatchQueue.global(qos: .utility)
            Alamofire.request("\(config.forKey(key: "base_url"))/api/v1/user/new", method: .post, parameters: ["device_type":"iOS"]).responseJSON(queue: queue){response in
                guard let value = response.result.value else{
                    self.checkApiKey()
                    return
                }
                if response.response?.statusCode != 200{
                    self.checkApiKey()
                    return
                }
                
                let responseJson = JSON(value)
                print(responseJson)
                
                keyStore["api_key"] = responseJson["secret"].stringValue
                
                semaphore.signal()
            }
            
            semaphore.wait()
            
        }
    }

}

