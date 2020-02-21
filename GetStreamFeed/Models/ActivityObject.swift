//
//  ActivityObject.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 22/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import GetStream

/// An activity object protocol.
public protocol ActivityObjectProtocol: Enrichable {
    var text: String? { get }
    var imageURL: URL? { get }
}

struct PostMeta: Codable {
    let image: String
    let text: String
}

/// An activity object with several subtypes: text, image, reposted activity, following user.
public enum ActivityObject: ActivityObjectProtocol {
    case unknown
    case text(_ value: String)
    case image(_ url: URL)
    case imageText(_ url: URL, _ value: String)
    case repost(_ activity: Activity)
    case following(_ user: User)
    
    public var referenceId: String {
        switch self {
        case .unknown:
            return ""
        case .text(let value):
            return value
        case .image(let url):
            return url.absoluteString
        case .imageText(let url, _):
            return url.absoluteString
        case .repost(let activity):
            return activity.referenceId
        case .following(let user):
            return user.referenceId
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .unknown:
            throw ActivityObjectError.unkownValue
        case .text(let value):
            try container.encode(value)
        case .image(let url):
            try container.encode(url)
        case .imageText(let url, let value):
            //try container.encode(url, value)
            break
        case .repost(let activity):
            try container.encode(activity)
        case .following(let user):
            try container.encode(user)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let text = try? container.decode(String.self) {
            print("print(text)")
            print(text)
            
            let data = text.data(using: .utf8)
            let decoder = JSONDecoder()
            if let parsedData = try? decoder.decode(PostMeta.self, from: data!) {
                let imageURL = URL(string: parsedData.image)
                self = .imageText(imageURL!, parsedData.text)
            } else {
                if text.hasPrefix("http"), let imageURL = URL(string: text) {
                    self = .image(imageURL)
                } else {
                    self = .text(text)
                }
            }
        } else if let activity = try? container.decode(Activity.self) {
            self = .repost(activity)
        } else {
            let safeUser = try container.decode(MissingReference<User>.self)
            
            if safeUser.decodingError == nil {
                self = .following(safeUser.value)
            } else {
                self = .unknown
            }
        }
    }
    
    public var isMissedReference: Bool {
        return text == "!missed_reference"
    }
    
    public static func missed() -> ActivityObject {
        return .text("!missed_reference")
    }
}

extension ActivityObject {
    
    /// A text, if the object contains the text.
    public var text: String? {
        if case .text(let value) = self {
            print(value)
            return value
        }
        
        return nil
    }
    
    /// An image URL, if the object contains the image URL.
    public var imageURL: URL? {
        if case .image(let url) = self {
            print(url)
            return url
        }
        
        return nil
    }
}

public enum ActivityObjectError: String, Error {
    case unkownValue
}
