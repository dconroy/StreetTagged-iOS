//
//  UIImageView+loadingImages.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 2/19/20.
//  Copyright © 2020 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit
import Nuke

extension UIImageView {
    private struct AssociatedKeys {
        static var imageTasksKey: UInt8 = 0
    }
    
    private var imageTasks: [ImageTask] {
        get { return (objc_getAssociatedObject(self, &AssociatedKeys.imageTasksKey) as? [ImageTask]) ?? [] }
        set { objc_setAssociatedObject(self, &AssociatedKeys.imageTasksKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// Load images with given URL's to UIImageView's in the stack view.
    /// The URL index from the array will match the UIImageView from the stack view.
    public func loadImages(with imageURLs: [URL]) {
        guard imageURLs.count > 0 else {
            return
        }
           
        print("loadImages")
        
        imageURLs.enumerated().forEach { index, url in
            let task = ImagePipeline.shared.loadImage(with: url) { [weak self] result in
                if let response = try? result.get() {
                    print("response")
                    self?.addImage(at: index, response.image)
                }
            }
            
            imageTasks.append(task)
        }
    }
    
    /// Cancel image loading tasks and set the `nil` to each image in `UIImageView` from the stack view.
    /// The `isHidden` property of `UIImageView` will be false.
    public func cancelImagesLoading() {
        self.image = nil;
        self.isHidden = false
        
        imageTasks.forEach { $0.cancel() }
        imageTasks = []
    }
    
    private func addImage(at index: Int, _ image: UIImage?) {
        print("addImage")
        print(image)
        self.image = image
        self.isHidden = false
    }
}
