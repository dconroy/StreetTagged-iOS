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

class FeedController: UICollectionViewController {
    let cellIDEmpty = "EmptyPostCell"
    let cellID = "postCell"
    
    var isRefreshingPosts: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        print("FeedController")
        refreshPosts()
        NotificationCenter.default.addObserver(self, selector: #selector(postedNotification), name: NSNotification.Name(rawValue: GLOBAL_POSTS_REFRESHED), object: nil)
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "showCamera").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(showCamera))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(shareButtonPressed))
        collectionView.refreshControl = refresh
    }
    
    @objc fileprivate func showCamera() {
        //let controller = UINavigationController(rootViewController: Camera())
        //present(controller, animated: true, completion: nil)
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
         print(posts.count)
         print(indexPath.row)
         if (indexPath.row == posts.count - 1) {
            print("reloadData")
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
        pageGetMorePosts()
    }
    
    @objc func shareButtonPressed() {

    }
    
    @objc func postedNotification() {
        print("postedNotification")
        self.refresh.endRefreshing()
        self.collectionView.reloadData()
        isRefreshingPosts = false
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
    func showComments(_ post: Post) {
        
    }
    
    func sharePost(_ image: UIImage) {
        
    }
}


