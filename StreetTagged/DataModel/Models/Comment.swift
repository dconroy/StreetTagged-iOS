//
//  Comment.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 9/15/19.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation

struct CommentItem {
    var profile: String
    var username: String
    var comment: String
    var time: TimeInterval
    
    init(data: [String: Any]) {
        self.username = data["username"] as! String
        self.profile = data["profile"] as! String
        self.comment = data["comment"] as! String
        self.time = data["time"] as! TimeInterval
    }
}
