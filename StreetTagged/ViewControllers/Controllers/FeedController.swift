//
//  FeedController.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 9/13/19.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import UIKit
import Foundation
import AWSMobileClient
import Alamofire
import AppleWelcomeScreen

class FeedController: UICollectionViewController {
    let cellIDEmpty = "EmptyPostCell"
    let cellID = "postCell"
    
    var isRefreshingPosts: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        refreshPosts()
        NotificationCenter.default.addObserver(self, selector: #selector(postedNotification), name: NSNotification.Name(rawValue: GLOBAL_POSTS_REFRESHED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(signUpNotification), name: NSNotification.Name(rawValue: GLOBAL_NEED_SIGN_UP), object: nil)
                
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var configuration = AWSConfigOptions()
               
        configuration.appName = "Street Tagged"
        configuration.appDescription = "Street Tagged is the easiest and most enjoyable way to find and share your favorite street art."
        configuration.tintColor = UIColor.gray
                     
        var item1 = AWSItem()
        item1.image = UIImage(named: "photo_1")
        item1.title = "Capture local street art"
        item1.description = "Post murals, post ups, and grafitti to share with the world."
                     
        var item2 = AWSItem()
        item2.image = UIImage(named: "find_1")
        item2.title = "Discover new favorites"
        item2.description = "Get push notifications when you are near popular art at home or while on the road."
                     
        var item3 = AWSItem()
        item3.image = UIImage(named: "me_1")
        item3.title = "Subscribe to your favorite artists."
        item3.description = "Get information about updates direct from the street artist."
                     
        configuration.items = [item1, item2, item3]
                     
        configuration.continueButtonAction = {
            self.dismiss(animated: true)
        }
               
        let vc = AWSViewController()
        vc.configuration = configuration
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    lazy var refresh: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.tintColor = .black
        refresh.addTarget(self, action: #selector(refreshAction), for: .allEvents)
        return refresh
    }()
    
    
    let titleView: UIImageView = {
        let view = UIImageView()
        //view.image = #imageLiteral(resourceName: "logo2").withRenderingMode(.alwaysOriginal)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    fileprivate func setup() {
        view.backgroundColor = .white
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(PostCell.self, forCellWithReuseIdentifier: cellID)
        navigationItem.titleView = titleView
        collectionView.refreshControl = refresh
        let filterItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filter))
        navigationItem.rightBarButtonItem = filterItem
    }
    
    @objc func filter() {
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count == 0 ? 0 : posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if posts.count == 0 {
            
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! PostCell
        cell.delegate = self
        if indexPath.item >= posts.count { return cell }
        cell.post = posts[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
         if (indexPath.row == posts.count - 1) {
            if (!isRefreshingPosts) {
                isRefreshingPosts = true
                pageGetMorePosts()
            }
         }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    @objc fileprivate func refreshAction() {
        topRefreshPost()
    }
    
    @objc func shareButtonPressed() {

    }
    
    @objc func postedNotification() {
        self.refresh.endRefreshing()
        self.collectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            self.isRefreshingPosts = false
        }
    }
    
    @objc func signUpNotification() {
        let alert = UIAlertController(title: "Are you logged in?", message: "Please sign in or create an account to favorite street art as well as submit art.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Sign In/Sign Up", style: UIAlertAction.Style.default, handler: { (alert: UIAlertAction!) in
            userSignIn(navController: self.navigationController!)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (alert: UIAlertAction!) in
            
        }))
        self.navigationController!.present(alert, animated: true, completion: nil)
    }
}

extension FeedController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if posts.count == 0 {
            let height = view.frame.height - (tabBarController?.tabBar.frame.height ?? 0) - (navigationController?.navigationBar.frame.height ?? 0) - UIApplication.shared.statusBarFrame.height
            return CGSize(width: view.frame.width, height: height)
        } else {
            if indexPath.item >= posts.count { return CGSize.zero}
            let textHeight = heightForView(post: posts[indexPath.item], width: view.frame.width - 16)
            var height: CGFloat = view.frame.width + 106 + textHeight + 5
            if posts[indexPath.item].additionalImages.count > 0 {
                height += 10
            }
            return CGSize(width: view.frame.width, height: height - 70)
        }
    }
}

extension FeedController: PostCellDelegate {
    func likePost(_ post: Post) {
        if (post.likes) {
            favoriteStreetPost(artId: post.id)
        } else {
            favoriteStreetRemove(artId: post.id)
        }
    }
    
    func sharePost(_ image: UIImage) {
        
    }
}


