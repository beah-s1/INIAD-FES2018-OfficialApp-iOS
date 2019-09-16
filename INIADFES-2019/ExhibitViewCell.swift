//
//  ExhibitViewCell.swift
//  INIADFES-2019
//
//  Created by Kentaro on 2019/09/17.
//  Copyright © 2019 Kentaro. All rights reserved.
//

import UIKit

class ExhibitViewCell: UITableViewCell {
    
    @IBOutlet weak var roomNum: UILabel!
    @IBOutlet weak var organizerName: UILabel!
    @IBOutlet weak var exhibitDescription: UILabel!
    @IBOutlet weak var exhibitImage: UIImageView!
    @IBOutlet weak var roomColor: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
