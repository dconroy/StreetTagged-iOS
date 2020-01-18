//
//  User.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 9/15/19.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation

struct AppUser {
    var username: String
    var profile: String
    var posts: Int
    var following: Int
    var followers: Int
    var uid: String?
    var usersFollowed: [String: Any]
    var usersFollowing: [String: Any]
    
    init(data: [String: Any]) {
        self.username = data["username"] as! String
        self.profile = data["profile"] as! String
        self.posts = data["posts"] as! Int
        self.following = data["following"] as! Int
        self.followers = data["followers"] as! Int
        self.usersFollowed = data["usersFollowed"] as? [String: Any] ?? [:]
        self.usersFollowing = data["usersFollowing"] as? [String: Any] ?? [:]
    }
}
