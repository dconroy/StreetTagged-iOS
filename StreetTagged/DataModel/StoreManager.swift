//
//  StoreManager.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 9/15/19.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit
import Realm
import AWSMobileClient
import Alamofire

let GLOBAL_POSTS_REFRESHED = "GLOBAL_POSTS_REFRESHED"

let cache = NSCache<AnyObject, UIImage>()
var posts: [Post] = []
var isRefreshingPosts = false

public func refreshPosts() {
    if (!isRefreshingPosts) {
        isRefreshingPosts = true
        AWSMobileClient.default().getTokens { (tokens, error) in
            if let error = error {
                print("Error getting token \(error.localizedDescription)")
            } else if let tokens = tokens {
                let parameters = ["token": tokens.accessToken!.tokenString!]
                
                Alamofire.request("https://api-dev.streettagged.com/search/art", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                    
                    do {
                        let decoder = JSONDecoder()
                        let artWorks = try decoder.decode(ArtWorks.self, from: response.data!)
                        print(artWorks)
                        for art in artWorks.artWorks {
                            let post: Post = Post.init(uid: "", id: art.artId, coordinates: art.location.coordinates ,dictionary: ["username":art.username, "image":art.picture, "created": 1568506837.12, "profile": "", "post":""]);
                            posts.append(post)
                            
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: GLOBAL_POSTS_REFRESHED), object: nil)
                            isRefreshingPosts = false
                        }
                        
                    } catch let error {
                        print(error.localizedDescription)
                        isRefreshingPosts = false
                    }
                }
            }
        }
    }
}
