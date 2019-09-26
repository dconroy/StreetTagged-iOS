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

let pageLimit = 5
var pageNumber = 1

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
        print("Alamofire.request")
        isRefreshingPosts = true
        if (userGlobalState == .userSignedIn) {
            getUserAWSAccessToken (completionHandler: { (token) in
                let parameters: [String : Any] = [
                    "pageNumber": pageNumber,
                    "pageLimit": pageLimit,
                    "token": token!
                ]
                Alamofire.request(searchURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        let artWorks = try decoder.decode(ArtWorks.self, from: response.data!)

                        for art in artWorks.items {
                            let formatter = ISO8601DateFormatter()
                            formatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
                            let date = formatter.date(from: art.createdAt)
                            
                            let post: Post = Post.init(uid: "", id: art.artId, coordinates: art.location.coordinates ,dictionary: ["username":art.username, "image":art.picture, "created": date!.timeIntervalSince1970, "profile": "", "post":""]);
                            posts.append(post)
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: GLOBAL_POSTS_REFRESHED), object: nil)
                        isRefreshingPosts = false
                    } catch let error {
                        print(error.localizedDescription)
                        isRefreshingPosts = false
                    }
                }
            })
            print("Done")
        } else {
            let parameters = [
                "pageNumber": pageNumber,
                "pageLimit": pageLimit
            ]
            Alamofire.request(searchURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let artWorks = try decoder.decode(ArtWorks.self, from: response.data!)

                    for art in artWorks.items {
                        let formatter = ISO8601DateFormatter()
                        formatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
                        let date = formatter.date(from: art.createdAt)
                        
                        let post: Post = Post.init(uid: "", id: art.artId, coordinates: art.location.coordinates ,dictionary: ["username":art.username, "image":art.picture, "created": date!.timeIntervalSince1970, "profile": "", "post":""]);
                        posts.append(post)
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: GLOBAL_POSTS_REFRESHED), object: nil)
                    isRefreshingPosts = false
                } catch let error {
                    print(error.localizedDescription)
                    isRefreshingPosts = false
                }
            }
            print("Done")
        }
    }
}

public func pageGetMorePosts() {
    pageNumber = pageNumber + 1
    refreshPosts()
}


