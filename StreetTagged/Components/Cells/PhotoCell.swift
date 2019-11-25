//
//  PhotoCell.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 9/15/19.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit

class PhotoCell: BaseCollectionViewCell {
    
    var index: Int?
    
    let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleToFill
        //image.backgroundColor = UIColor.black
        image.clipsToBounds = true
        return image
    }()
    
    override func setup() {
        addSubview(imageView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: imageView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: imageView)
    }
    
    public func setImage(image: UIImage) {
        imageView.image = image
    }
    
    public func getImage() -> UIImage? {
        return imageView.image
    }
    
    public func resetImage() {
        imageView.image = nil
        //imageView.backgroundColor = .black
    }
}
