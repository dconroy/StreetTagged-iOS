//
//  File.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 9/15/19.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit

struct LabelProperties {
    var font: UIFont
    var text: String
    var location: CGPoint
    var color: UIColor
}

class Post: NSObject {
    var image: String
    var created: TimeInterval
    var about: String
    var username: String
    var profile: String
    var id: String
    var uid: String
    var comments: [String: Any]
    var likes: Bool
    var bookmarks: [String: Any]
    var additionalImages: [String: String]
    var coordinates: [Float]
    
    init(uid: String, id: String, coordinates:[Float], dictionary: [String: Any]) {
        self.image = dictionary["image"] as! String
        self.created = dictionary["created"] as! TimeInterval
        self.about = dictionary["about"] as? String ?? ""
        self.username = dictionary["username"] as! String
        self.profile = dictionary["profile"] as! String
        self.comments = dictionary["comments"] as? [String: Any] ?? [:]
        if (dictionary["likes"] == nil) {
            self.likes = false
        } else {
            self.likes = dictionary["likes"] as? Bool ?? false
        }
        self.bookmarks = dictionary["bookmarks"] as? [String: Any] ?? [:]
        self.additionalImages =  dictionary["additionalImages"] as? [String: String] ?? [:]
        self.id = id
        self.uid = uid
        self.coordinates = coordinates
    }
    
    override var description: String {
        get {
            return self.about
        }
    }
}
