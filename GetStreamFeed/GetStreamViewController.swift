//
//  GetStreamViewController.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 2/18/20.
//  Copyright © 2020 John O'Sullivan. All rights reserved.
//

import UIKit
import GetStream

import AppleWelcomeScreen
import SPPermissions

public struct SequenceDiff<T1, T2> {
    public let common: [(T1, T2)]
    public let removed: [T1]
    public let inserted: [T2]
    public init(common: [(T1, T2)] = [], removed: [T1] = [], inserted: [T2] = []) {
        self.common = common
        self.removed = removed
        self.inserted = inserted
    }
}

class GetStreamViewController: FlatFeedViewController<Activity> {
    
    let textToolBar = TextToolBar.make()
    var timelineFlatFeed: FlatFeed?
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTagsFollowers), name: NSNotification.Name(rawValue: GLOBAL_GET_STREAM_UPDATE_TAGS), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        isFirstLaunch();
    }
    
    public func diffInTags<T1, T2>(_ first: [T1], _ second: [T2], with compare:(T1,T2) -> Bool) -> SequenceDiff<T1, T2> {
        let removed: [T1] = first.filter { firstElement in !second.contains { secondElement in compare(firstElement, secondElement) } }
        let inserted: [T2] = second.filter { secondElement in !first.contains { firstElement in compare(firstElement, secondElement) } }
        let combinations = first.flatMap { firstElement in second.compactMap { secondElement in (firstElement, secondElement) } }
        let common = combinations.filter { compare($0.0, $0.1) }
        return SequenceDiff(common: common, removed: removed, inserted: inserted)
    }
    
    @objc func updateTagsFollowers(notification: NSNotification) {
        let notificationTags = notification.object as! NSArray
        
        let newTags = notificationTags.map({ (tagRaw) -> String in
            return String((tagRaw as! String).dropFirst(1))
        });
                
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let followers: [Follower] = appDelegate.getGetStreamFollowers()
        
        let currentTags = followers.map({ (follower) -> String in
            return follower.targetFeedId.userId
        });
        
        let updates = diffInTags(currentTags,newTags, with: ==)
        
        let tagUpdatesGroup = DispatchGroup()
        
        for tag in updates.inserted {
            tagUpdatesGroup.enter()
            self.timelineFlatFeed!.follow(toTarget: FeedId(feedSlug: "tag", userId: tag), completion: { result in
                tagUpdatesGroup.leave()
            })
        }
        
        for tag in updates.removed {
            tagUpdatesGroup.enter()
            self.timelineFlatFeed!.unfollow(fromTarget: FeedId(feedSlug: "tag", userId: tag), keepHistory: true, completion: { result in
                tagUpdatesGroup.leave()
            })
        }
        
        tagUpdatesGroup.notify(queue: .main) {
            self.reloadData()
            self.timelineFlatFeed!.following(completion: { result in
                do {
                    let response = try result.get()
                    DispatchQueue.main.async {
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.setGetStreamFollowers(follower: response.results)
                    }
                } catch _ { }
            })
        }
    }
    
    public func updateSetup() {
        if let feedId = FeedId(feedSlug: "timeline") {
            self.timelineFlatFeed = Client.shared.flatFeed(feedId)
            presenter = FlatFeedPresenter<Activity>(flatFeed: self.timelineFlatFeed!, reactionTypes: [.likes, .comments])
            // Grabs the current feeds thats are being followed
            self.timelineFlatFeed!.following(completion: { result in
                do {
                    let response = try result.get()
                    DispatchQueue.main.async {
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.setGetStreamFollowers(follower: response.results)
                    }
                } catch _ { }
            })
        }
        super.viewDidLoad()
        subscribeForUpdates()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let detailViewController = DetailViewController<Activity>()
            detailViewController.activityPresenter = activityPresenter(in: indexPath.section)
            detailViewController.sections = [.activity, .comments]

            let navigationController = UINavigationController(rootViewController: detailViewController)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
        } else {
            super.tableView(tableView, didSelectRowAt: indexPath)
        }
    }
    
    func isFirstLaunch() {
        if (UserDefaults.isFirstLaunch()) {
            var configuration = AWSConfigOptions()
            
            configuration.appName = "Street Tagged"
            configuration.appDescription = "Street Tagged is the easiest and most enjoyable way to find and share your favorite street art."
            configuration.tintColor = UIColor.gray

            var item1 = AWSItem()
            item1.image = UIImage(named: "photo_big-1")
            item1.title = "Capture local street art"
            item1.description = "Post murals, post ups, and grafitti to share with the world."

            var item2 = AWSItem()
            item2.image = UIImage(named: "find_1")
            item2.title = "Discover new favorites"
            item2.description = "Get push notifications when you are near popular art at home or while on the road."

            var item3 = AWSItem()
            item3.image = UIImage(named: "me_1")
            item3.title = "Subscribe to your favorite artists."
            item3.description = "Get information and updates direct from the street artists."

            configuration.items = [item1, item2, item3]

            configuration.continueButtonAction = {
                self.dismiss(animated: true)
                let controller = SPPermissions.list([.camera, .notification, .locationWhenInUse, .photoLibrary])
                controller.dataSource = self
                controller.delegate = self
                controller.present(on: self)
            }

            let vc = AWSViewController()
            vc.configuration = configuration
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }  else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: GLOBAL_START_LOCATION_MANAGER), object: nil)
        }
    }
}

extension GetStreamViewController: SPPermissionsDataSource, SPPermissionsDelegate {
    
    /**
     Configure permission cell here.
     You can return permission if want use default values.
     
     - parameter cell: Cell for configure. You can change all data.
     - parameter permission: Configure cell for it permission.
     */
    func configure(_ cell: SPPermissionTableViewCell, for permission: SPPermission) -> SPPermissionTableViewCell {
        
        /*
         // Titles
         cell.permissionTitleLabel.text = "Notifications"
         cell.permissionDescriptionLabel.text = "Remind about payment to your bank"
         cell.button.allowTitle = "Allow"
         cell.button.allowedTitle = "Allowed"
         
         // Colors
         cell.iconView.color = .systemBlue
         cell.button.allowedBackgroundColor = .systemBlue
         cell.button.allowTitleColor = .systemBlue
         
         // If you want set custom image.
         cell.set(UIImage(named: "IMAGE-NAME")!)
         */
        
        return cell
    }
    
    /**
     Call when controller closed.
     
     - parameter ids: Permissions ids, which using this controller.
     */
    func didHide(permissions ids: [Int]) {
        let permissions = ids.map { SPPermission(rawValue: $0)! }
        print("Did hide with permissions: ", permissions.map { $0.name })
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: GLOBAL_START_LOCATION_MANAGER), object: nil)
    }
    
    /**
     Alert if permission denied. For disable alert return `nil`.
     If this method not implement, alert will be show with default titles.
     
     - parameter permission: Denied alert data for this permission.
     */
    func deniedData(for permission: SPPermission) -> SPPermissionDeniedAlertData? {
        if permission == .notification {
            let data = SPPermissionDeniedAlertData()
            data.alertOpenSettingsDeniedPermissionTitle = "Permission denied"
            data.alertOpenSettingsDeniedPermissionDescription = "Please, go to Settings and allow permission."
            data.alertOpenSettingsDeniedPermissionButtonTitle = "Settings"
            data.alertOpenSettingsDeniedPermissionCancelTitle = "Cancel"
            return data
        } else {
            // If returned nil, alert will not show.
            return nil
        }
    }
}

