//
//  Globals.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 9/22/19.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    static var appAPIURL: String? {
        return Bundle.main.object(forInfoDictionaryKey: "AppAPIBaseURL") as? String
    }
}

let GLOBAL_POSTS_REFRESHED = "GLOBAL_POSTS_REFRESHED"
let GLOBAL_TOKEN_GET_ERROR = "GLOBAL_TOKEN_GET_ERROR"

let GLOBAL_AWS_S3_UPLOAD_BUCKET = "s3debugingtesting"

let searchURL = UIApplication.appAPIURL! + "/items/search"

func imageURLFromS3Key(key: String) -> String {
    return "https://" + GLOBAL_AWS_S3_UPLOAD_BUCKET + ".s3.amazonaws.com/" + key
}

