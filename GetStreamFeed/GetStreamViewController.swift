//
//  GetStreamViewController.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 2/18/20.
//  Copyright © 2020 John O'Sullivan. All rights reserved.
//

import UIKit
import GetStream
//import GetStreamActivityFeed


class GetStreamViewController: FlatFeedViewController<Activity> {
    
    let textToolBar = TextToolBar.make()
    
    override func viewDidLoad() {

        // Setup a timeline feed presenter.
        if let feedId = FeedId(feedSlug: "timeline") {
            let timelineFlatFeed = Client.shared.flatFeed(feedId)
            
           /* timelineFlatFeed.follow(toTarget: FeedId(feedSlug: "tag", userId: "badbitch")) { result in
                print(result)
            }*/
            
            /*
            timelineFlatFeed.follow(toTarget: FeedId(feedSlug: "timeline", userId: "e7ce172e-e170-4070-92ed-ded3ce66c947")) { result in
                print(result)
            }*/

            print(feedId)
            print(timelineFlatFeed)
            
            presenter = FlatFeedPresenter<Activity>(flatFeed: timelineFlatFeed, reactionTypes: [.likes, .comments, .reposts])
            
          /*  timelineFlatFeed.get() { result in
                print("timelineFlatFeed.get()")
                print(result)
            }
            
            let notificationFeed = NotificationFeed(FeedId(feedSlug: "notification", userId: "88a5aa64-29ea-4fe3-8c8f-deacee160794"))
            var subscriptionId: SubscriptionId?
            var x: NotificationsPresenter<GetStream.Activity>?
            
            x = NotificationsPresenter(notificationFeed)
            
            subscriptionId = x!.subscriptionPresenter.subscribe { [weak self] in
                if let _ = self, let response = try? $0.get() {
                    print(response)
                }
                print("There was a Notification")
            } */
            
            
          
            
            // Create an Activity. You can make own Activity class or struct with custom properties.
            //let activity = Activity(actor: User.current!, verb: "add", object: "without the frontend app")

            /*timelineFlatFeed.add(activity) { result in
                // A result of the adding of the activity.
                print("timelineFlatFeed.add(activity)")
                print(result)
            }*/
            
            /*let userFeed = Client.shared.flatFeed(feedSlug: "user")
            let activity = Activity(actor: User.current!, verb: "pin", object: "Place:42")

            userFeed?.add(activity) { result in
                if let activity = try? result.get() {
                    // Added activity
                    print(activity.id)
                }
            }*/
        }
        
        super.viewDidLoad()
        //setupTextToolBar()
        subscribeForUpdates()
        
        
    }
    
    func setupTextToolBar() {
        textToolBar.addToSuperview(view, placeholderText: "Share something...")
        // Enable URL unfurling.
        textToolBar.linksDetectorEnabled = true
        // Enable image picker.
        textToolBar.enableImagePicking(with: self)
        textToolBar.sendButton.addTarget(self, action: #selector(save(_:)), for: .touchUpInside)
    }
    
    @objc func save(_ sender: UIButton) {
        // Hide the keyboard.
        view.endEditing(true)
        
        // Check that entered text is not empty
        // and get the current user, it shouldn’t be nil.
        if textToolBar.isValidContent, let presenter = presenter {
            textToolBar.addActivity(to: presenter.flatFeed) { result in
                print(result)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            // Create a detail view controller.
            let detailViewController = DetailViewController<Activity>()
            // Set the activity presenter from the selected cell.
            detailViewController.activityPresenter = activityPresenter(in: indexPath.section)
            // Set sections we want to show the activity itself and comments.
            detailViewController.sections = [.activity, .comments]
            // Present the detail view controller with UINavigationController
            // to use the navigation bar to return back.
            present(UINavigationController(rootViewController: detailViewController), animated: true)
        } else {
            // Keep the default behaviour for over rows in the table view.
            super.tableView(tableView, didSelectRowAt: indexPath)
        }
    }
}
