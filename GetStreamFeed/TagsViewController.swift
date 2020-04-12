//
//  TagsViewController.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 2/23/20.
//  Copyright © 2020 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AWSCore
import AWSMobileClient
import AWSS3
import CoreLocation
import UserNotifications
import MapKit
import Eureka
import Lightbox
import Photos
import Alamofire
import GetStream

public final class ImageCheckRow<T: Equatable>: Row<ImageCheckCell<T>>, SelectableRowType, RowType {
    public var selectableValue: T?
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

public class ImageCheckCell<T: Equatable> : Cell<T>, CellType {

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Image for selected state
    lazy public var trueImage: UIImage = {
        return UIImage(named: "selected")!
    }()

    /// Image for unselected state
    lazy public var falseImage: UIImage = {
        return UIImage(named: "unselected")!
    }()

    public override func update() {
        super.update()
        checkImageView?.image = row.value != nil ? trueImage : falseImage
        checkImageView?.sizeToFit()
    }
    
    /// Image view to render images. If `accessoryType` is set to `checkmark`
    /// will create a new `UIImageView` and set it as `accessoryView`.
    /// Otherwise returns `self.imageView`.
    open var checkImageView: UIImageView? {
        guard accessoryType == .checkmark else {
            return self.imageView
        }
        
        guard let accessoryView = accessoryView else {
            let imageView = UIImageView()
            self.accessoryView = imageView
            return imageView
        }
        
        return accessoryView as? UIImageView
    }

    public override func setup() {
        super.setup()
        accessoryType = .none
    }

    public override func didSelect() {
        row.reload()
        row.select()
        row.deselect()
    }

}

class TagsViewController: FormViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    var currentTages: Any?
    
    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func apply() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: GLOBAL_GET_STREAM_UPDATE_TAGS), object: currentTages)
        self.dismiss(animated: true, completion: nil)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Select Tags"
        
        let cancelItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        navigationItem.leftBarButtonItem = cancelItem
        
        let applyItem = UIBarButtonItem(title: "Apply", style: .plain, target: self, action: #selector(apply))
        navigationItem.rightBarButtonItem = applyItem
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let followers: [Follower] = appDelegate.getGetStreamFollowers()
                
        let currentTags = followers.map({ (follower) -> String in
            let hashtag = follower.targetFeedId.userId
            return "#" + hashtag
        });
        
        Alamofire.request(streamGetTags, method: .get, encoding: JSONEncoding.default).responseJSON { response in
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let tags = try decoder.decode(TagsRespsonse.self, from: response.data!)
                
                print(tags.tags)
                
                self.form +++ SelectableSection<ImageCheckRow<String>>("Please select the tags of art work you will like to see your feed.", selectionType: .multipleSelection)
                for option in tags.tags {
                    self.form.last! <<< ImageCheckRow<String>(option){ lrow in
                        lrow.title = option
                        lrow.selectableValue = option
                        
                        if currentTags.contains(option) {
                            lrow.value = option
                        } else {
                            lrow.value = nil
                        }
                        
                        }.cellSetup { cell, _ in
                            cell.trueImage = UIImage(named: "selectedRectangle")!
                            cell.falseImage = UIImage(named: "unselectedRectangle")!
                            cell.accessoryType = .checkmark
                    }
                }
                
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    override func valueHasBeenChanged(for row: BaseRow, oldValue: Any?, newValue: Any?) {
        currentTages = ((row.section as! SelectableSection<ImageCheckRow<String>>).selectedRows().map({$0.baseValue}))
        print("Mutiple Selection:\((row.section as! SelectableSection<ImageCheckRow<String>>).selectedRows().map({$0.baseValue}))")
    }
        
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}
