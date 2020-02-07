//
//  String.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 1/19/20.
//  Copyright © 2020 John O'Sullivan. All rights reserved.
//

import Foundation

extension String
{
    func hashTags() -> [String]
    {
        if let regex = try? NSRegularExpression(pattern: "#[a-z0-9]+", options: .caseInsensitive)
        {
            let string = self as NSString
            
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range).lowercased()
            }
        }
        return []
    }
}
