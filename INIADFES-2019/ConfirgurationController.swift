//
//  ConfirgurationController.swift
//  INIADFES-2019
//
//  Created by Kentaro on 2019/09/24.
//  Copyright © 2019 Kentaro. All rights reserved.
//

import Foundation
import UIKit

class Configuration{
    private var dict:NSDictionary
    
    init() {
        guard let path = Bundle.main.path(forResource: "configuration", ofType: "plist") else{
            //assert(false, )
            fatalError("COULD NOT FIND CONFIGURATION FILE")
        }
        self.dict = NSDictionary(contentsOfFile: path)!
    }
    
    func forKey(key:String) -> String{
        if let value = self.dict[key] as? String{
            return value
        }else{
            return ""
        }
    }
}
