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

var favoritePosts: [Post] = []

var postAlls: [Post] = []

var favoritePostAlls: [Post] = []

var isRefreshingPosts = false

let pageLimit = 20
var pageNumber = 1

var nearByPosts: [Post] = []

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

public func topRefreshPost() {
    pageNumber = 1
    posts.removeAll()
    postAlls.removeAll()
    refreshPosts()
}

public func refreshPosts() {
    if (!isRefreshingPosts) {
        print("Alamofire.request - refreshPosts")
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
                            
                            let post: Post = Post.init(uid: "", id: art.artId, coordinates: art.location.coordinates ,dictionary: ["username":art.username, "image":art.picture, "created": date!.timeIntervalSince1970, "profile": "", "about":art.about, "likes": art.isFavorited]);
                                                        
                            postAlls.append(post)
                        }
                        posts = postAlls.sorted(by: { $0.created > $1.created })
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: GLOBAL_POSTS_REFRESHED), object: nil)
                        isRefreshingPosts = false
                    } catch let error {
                        print(error.localizedDescription)
                        isRefreshingPosts = false
                    }
                }
            })
        } else {
            let parameters = [
                "pageNumber": pageNumber,
                "pageLimit": pageLimit
            ]
            print(parameters)
            Alamofire.request(searchURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let artWorks = try decoder.decode(ArtWorks.self, from: response.data!)
                                        
                    for art in artWorks.items {
                        let formatter = ISO8601DateFormatter()
                        formatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
                        let date = formatter.date(from: art.createdAt)
                        
                        let post: Post = Post.init(uid: "", id: art.artId, coordinates: art.location.coordinates ,dictionary: ["username":art.username, "image":art.picture, "created": date!.timeIntervalSince1970, "profile": "", "about":art.about]);
                        
                        postAlls.append(post)
                    }
                    posts = postAlls.sorted(by: { $0.created > $1.created })
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: GLOBAL_POSTS_REFRESHED), object: nil)
                    isRefreshingPosts = false
                } catch let error {
                    print(error.localizedDescription)
                    isRefreshingPosts = false
                }
            }
        }
    }
}


public func allStreetArt() {
    getUserAWSAccessToken (completionHandler: { (token) in
            Alamofire.request(getItemURL, method: .get, encoding: JSONEncoding.default).responseJSON { response in
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let artWorks = try decoder.decode(ArtWorks.self, from: response.data!)
                      
                nearByPosts.removeAll()
                
                for art in artWorks.items {
                    let formatter = ISO8601DateFormatter()
                    formatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
                    let date = formatter.date(from: art.createdAt)
                    
                    let post: Post = Post.init(uid: "", id: art.artId, coordinates: art.location.coordinates ,dictionary: ["username":art.username, "image":art.picture, "created": date!.timeIntervalSince1970, "profile": "", "about":art.about]);
                    
                    nearByPosts.append(post)
                }

                NotificationCenter.default.post(name: NSNotification.Name(rawValue: GLOBAL_ALL_REFRESHED), object: nil)
            } catch let error {
                print(error.localizedDescription)
            }
        }

    })
}

public func favoriteStreetList() {
    getUserAWSAccessToken (completionHandler: { (token) in
            Alamofire.request(urlFavorite + "?token=" + token! + "&pageLimit=1000", method: .get, encoding: JSONEncoding.default).responseJSON { response in
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let artWorks = try decoder.decode(FavoriteArtWorks.self, from: response.data!)
                      
                favoritePostAlls.removeAll()
                
                for art in artWorks.artWorks {
                    let formatter = ISO8601DateFormatter()
                    formatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
                    let date = formatter.date(from: art.createdAt)
                    
                    let post: Post = Post.init(uid: "", id: art.artId, coordinates: art.location.coordinates ,dictionary: ["username":art.username, "image":art.picture, "created": date!.timeIntervalSince1970, "profile": "", "about":art.about]);
                    
                    favoritePostAlls.append(post)
                }
                favoritePosts.removeAll()
                favoritePosts = favoritePostAlls.sorted(by: { $0.created > $1.created })
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: GLOBAL_FAVS_REFRESHED), object: nil)
            } catch let error {
                print(error.localizedDescription)
            }
        }

    })
}

public func favoriteStreetPost(artId: String) {
    getUserAWSAccessToken (completionHandler: { (token) in
        let parameters: [String : Any] = [
            "itemId": artId,
            "token": token!
        ]
        Alamofire.request(urlFavorite, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            print(response.response ?? "No Status")
        }
    })
}

public func favoriteStreetRemove(artId: String) {
    getUserAWSAccessToken (completionHandler: { (token) in
        let parameters: [String : Any] = [
            "itemId": artId,
            "token": token!
        ]
        Alamofire.request(urlFavorite, method: .delete, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            print(response.response ?? "No Status")
        }
    })
}

public func pageGetMorePosts() {
    pageNumber = pageNumber + 1
    refreshPosts()
}
