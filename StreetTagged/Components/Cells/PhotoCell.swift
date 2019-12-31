//
//  PhotoCell.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 9/15/19.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class PhotoCell: BaseCollectionViewCell {
    var index: Int?
    
    let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleToFill
        image.clipsToBounds = true
        return image
    }()
    
    override func setup() {
        addSubview(imageView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: imageView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: imageView)
    }
    
    public func setImage(imageURL: String) {
        let url = URL(string: imageURL)
        imageView.kf.setImage(with: url)
    }
    
    public func getImage() -> UIImage? {
        return imageView.image
    }
}
