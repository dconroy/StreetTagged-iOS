//
//  HelpFunctions.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 9/15/19.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

public func getTimeElapsed(_ time: TimeInterval) -> String{
    let diff = Date().timeIntervalSince1970 - time
    if diff < 60 {
        return String.init(format: "%.0f seconds ago", diff)
    } else if diff < 3600 {
        return String.init(format: "%.0f minutes ago", diff/60)
    } else if diff < 86400 {
        return String.init(format: "%.0f hours ago", diff/3600)
    } else if diff < 604800 {
        return String.init(format: "%.0f days ago", diff/86400)
    } else if diff < 2.628e+6 {
        return String.init(format: "%.0f weeks ago", diff/604800)
    } else if diff < 3.154e+7 {
        return String.init(format: "%.0f months ago", diff/2.628e+6)
    }
    return String.init(format: "%.0f years ago", diff/3.154e+7)
}

func getCurrentMillis()->Int64 {
    return Int64(Date().timeIntervalSince1970 * 1000)
}

func heightForView(post: Post, width: CGFloat) -> CGFloat{
    let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    let attributedText = NSMutableAttributedString(string: post.username + " ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
    attributedText.append(NSAttributedString(string: post.post , attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]))
    attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 4)]))
    attributedText.append(NSAttributedString(string: getTimeElapsed(post.created), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: UIColor.gray]))
    label.attributedText = attributedText
    label.sizeToFit()
    
    return label.frame.height
}

func heightForCommentView(comment: CommentItem, width: CGFloat) -> CGFloat{
    let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    let attributedText = NSMutableAttributedString(string: comment.username + " ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
    attributedText.append(NSAttributedString(string: comment.comment, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: UIColor.black]))
    label.attributedText = attributedText
    label.sizeToFit()
    
    return label.frame.height
}

//MARK: Visual Constraints
extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated(){
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
    func center_X(item: UIView) {
        center_X(item: item, constant: 0)
    }
    
    func center_X(item: UIView, constant: CGFloat) {
        self.addConstraint(NSLayoutConstraint(item: item, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: constant))
    }
    
    func center_Y(item: UIView, constant: CGFloat) {
        self.addConstraint(NSLayoutConstraint(item: item, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: constant))
    }
    
    func center_Y(item: UIView) {
        center_Y(item: item, constant: 0)
    }
    
    func dataForViewAsImage() -> Data?{
        let size = frame.size
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        guard let i = UIGraphicsGetImageFromCurrentImageContext(),
            let data = i.jpegData(compressionQuality: 1.0)
            else {return nil}
        UIGraphicsEndImageContext()
        
        return data
    }
}


//MARK: Colors Used
extension UIColor {
    
    //MARK: function
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
    }
    
    //MARK: Colors
    static let lighterBlack = UIColor(r: 234, g: 234, b: 234)
    static let textfiled = UIColor(r: 250, g: 250, b: 250)
    static let blueInstagram = UIColor(r: 69, g: 142, b: 255)
    static let blueInstagramLighter = UIColor(r: 69, g: 142, b: 195)
    static let blueButton = UIColor(r: 154, g: 204, b: 246)
    static let buttonUnselected = UIColor(white: 0, alpha: 0.25)
    static let shareBackground = UIColor(r: 240, g: 240, b: 240)
    static let searchBackground = UIColor(r: 230, g: 230, b: 230)
    static let seperator = UIColor(white: 0, alpha: 0.50)
    static let highlightedButton = UIColor(r: 17, g: 154, b: 237)
    static let save = UIColor(white: 0, alpha: 0.3)
}

//MARK: Image Extensions
extension UIImageView {
    func loadImage(_ url: String, completion: (() -> Void)? = nil) {
        if let image = cache.object(forKey: url as AnyObject) {
            self.image = image
            return
        }
        Alamofire.request(url).responseData { response in
            if let data = response.data {
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.image = image
                    if let image = image {
                        cache.setObject(image, forKey: url as AnyObject)
                    }
                    completion?()
                }
            }
        }
    }
}
