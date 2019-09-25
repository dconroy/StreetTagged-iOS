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

let cache = NSCache<AnyObject, UIImage>()
var posts: [Post] = []
var isRefreshingPosts = false

extension String {

  func epoch(dateFormat: String = "d MMMM yyyy", timeZone: String? = nil) -> TimeInterval? {
    // building the formatter
    let formatter = DateFormatter()
    formatter.dateFormat = dateFormat
    if let timeZone = timeZone { formatter.timeZone = TimeZone(identifier: timeZone) }

    // extracting the epoch
    let date = formatter.date(from: self)
    return date?.timeIntervalSince1970
  }

}

public func refreshPosts() {
    if (!isRefreshingPosts) {
        isRefreshingPosts = true
        print("refreshPosts 1")
        //AWSMobileClient.default().getTokens { (tokens, error) in
            
            let parameters = ["pageNumber": 1, "pageLimit": 100]
            print("refreshPosts 2")
            
            Alamofire.request(searchURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                
                do {
                    posts.removeAll()
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let artWorks = try decoder.decode(ArtWorks.self, from: response.data!)
                    print(artWorks)
                    for art in artWorks.items {
                        
                        let formatter = ISO8601DateFormatter()
                        formatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
                        let date = formatter.date(from: art.createdAt)
                        
                        let post: Post = Post.init(uid: "", id: art.artId, coordinates: art.location.coordinates ,dictionary: ["username":art.username, "image":art.picture, "created": date!.timeIntervalSince1970, "profile": "", "post":""]);
                        posts.append(post)
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: GLOBAL_POSTS_REFRESHED), object: nil)
                        isRefreshingPosts = false
                    }

                    posts.reverse()
                } catch let error {
                    print(error.localizedDescription)
                    isRefreshingPosts = false
                }
            }
            
        //}
    }
}


