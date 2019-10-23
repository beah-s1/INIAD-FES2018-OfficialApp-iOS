//
//  Objects.swift
//  INIADFES-2019
//
//  Created by Kentaro on 2019/09/24.
//  Copyright © 2019 Kentaro. All rights reserved.
//

import Foundation

struct Content{
    var ucode = ""
    var title = ""
    var description = ""
    var organizer = ""
    var place = Room()
    var imageUrl = ""
}

struct Room{
    var ucode = ""
    var roomName = ""
    var doorNames = [String]()
    var roomColorCode = ""
}
