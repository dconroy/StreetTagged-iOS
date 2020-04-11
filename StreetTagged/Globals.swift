//
//  Globals.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 9/22/19.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

var globalSimpleMode: Bool = false

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    static var appAPIURL: String? {
        return Bundle.main.object(forInfoDictionaryKey: "AppAPIBaseURL") as? String
    }
    static var getStreamApiKey: String? {
        return Bundle.main.object(forInfoDictionaryKey: "GetStreamAPIKey") as? String
    }
    static var getStreamAppId: String? {
        return Bundle.main.object(forInfoDictionaryKey: "GetStreamAppID") as? String
    }
}

extension UserDefaults {
    static func isFirstLaunch() -> Bool {
        let launchedBeforeFlag = "launchedBeforeFlag"
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: launchedBeforeFlag)
        if (isFirstLaunch) {
            UserDefaults.standard.set(true, forKey: launchedBeforeFlag)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }
}

extension CLLocationDistance {
    func inMiles() -> CLLocationDistance {
        return self*0.00062137
    }

    func inKilometers() -> CLLocationDistance {
        return self/1000
    }
}

func getDistanceFromGlobalLocation(artLocation: CLLocation) -> String {
    let meters = globalLocation.distance(from: artLocation)
    return " - " + String(format:"%.1f", meters.inMiles()) + " miles away"
}

let GLOBAL_SIGNIN_REFRESH = "GLOBAL_SIGNIN_REFRESH"
let GLOBAL_POSTS_REFRESHED = "GLOBAL_POSTS_REFRESHED"
let GLOBAL_FAVS_REFRESHED = "GLOBAL_FAVS_REFRESHED"
let GLOBAL_ALL_REFRESHED = "GLOBAL_ALL_REFRESHED"
let GLOBAL_TOKEN_GET_ERROR = "GLOBAL_TOKEN_GET_ERROR"
let GLOBAL_NEED_SIGN_UP = "GLOBAL_NEED_SIGN_UP"
let GLOBAL_START_LOCATION_MANAGER = "GLOBAL_START_LOCATION_MANAGER"

let GLOBAL_GET_STREAM_UPDATE_TAGS = "GLOBAL_GET_STREAM_UPDATE_TAGS"

let GLOBAL_CDN = "images.streettagged.com"

let searchURL = UIApplication.appAPIURL! + "/items/search"

let postItemURL = UIApplication.appAPIURL! + "/items"
let moderationTagsURL = UIApplication.appAPIURL! + "/tags/moderation"
let tagsURL = UIApplication.appAPIURL! + "/tags"
let urlFavorite = UIApplication.appAPIURL! + "/favorites"
let getItemURL = UIApplication.appAPIURL! + "/items"
let s3Bucket = "streetartprod"

let GET_STREAM_GLOBAL_FEED_NAME = "global_user"

let streamTokenURL = UIApplication.appAPIURL! + "/stream/token"
let streamGetTags = UIApplication.appAPIURL! + "/stream/tags"

func imageURLFromS3Key(key: String, filter: String) -> String {
    return "https://" + GLOBAL_CDN + "/" + filter + "/" + key
}

