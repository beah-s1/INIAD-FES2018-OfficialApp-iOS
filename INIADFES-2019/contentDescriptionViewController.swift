//
//  contentDescriptionViewController.swift
//  INIADFES-2019
//
//  Created by Kentaro on 2019/10/24.
//  Copyright © 2019 Kentaro. All rights reserved.
//

import Foundation
import UIKit

class ContentDescriptionViewController:UIViewController{
    
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var contentTitleText: UILabel!
    @IBOutlet weak var roomAndOrganizationText: UILabel!
    @IBOutlet weak var contentDescriptionText: UITextView!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
