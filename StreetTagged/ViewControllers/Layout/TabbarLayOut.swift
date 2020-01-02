//
//  ExampleProvider.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 9/13/19.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import UIKit
import ESTabBarController_swift

enum TabbarLayOut {
    static func tabbar(delegate: UITabBarControllerDelegate?) -> BasicNavigationController {
        let tabBarController = ESTabBarController()
        tabBarController.delegate = delegate
        tabBarController.title = "Irregularity"
        tabBarController.tabBar.shadowImage = UIImage(named: "transparent")
        tabBarController.tabBar.backgroundImage = UIImage(named: "background")
        tabBarController.shouldHijackHandler = {
            tabbarController, viewController, index in
            if index == 2 {
                return true
            }
            
            if index == 0 {
                tabBarController.title = "Feed"
            }
            if index == 1 {
                tabBarController.title = "Nearby"
            }
            if index == 3 {
                tabBarController.title = "Favorites"
            }
            if index == 4 {
                tabBarController.title = "Me"
            }
            
            return false
        }
        tabBarController.didHijackHandler = {
            [weak tabBarController] tabbarController, viewController, index in
            
            if index == 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: .alert)
                    let takePhotoAction = UIAlertAction(title: "Take a photo", style: .default, handler: nil)
                    alertController.addAction(takePhotoAction)
                    let selectFromAlbumAction = UIAlertAction(title: "Select from album", style: .default, handler: nil)
                    alertController.addAction(selectFromAlbumAction)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    tabBarController?.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
        let flow = UICollectionViewFlowLayout()
        let v1 = FeedController(collectionViewLayout: flow)
        let v2 = NearByController()
        let v3 = FavorController()
        let v4 = FavorController()
        let v5 = FavorController()
        
        v1.tabBarItem = ESTabBarItem.init(TabBasicContentView(), title: "Feed", image: UIImage(named: "home"), selectedImage: UIImage(named: "home_1"))
        v2.tabBarItem = ESTabBarItem.init(TabBasicContentView(), title: "Nearby", image: UIImage(named: "find"), selectedImage: UIImage(named: "find_1"))
        v3.tabBarItem = ESTabBarItem.init(TabContentView(), title: nil, image: UIImage(named: "photo_verybig"), selectedImage: UIImage(named: "photo_verybig"))
        v4.tabBarItem = ESTabBarItem.init(TabBasicContentView(), title: "Favorites", image: UIImage(named: "favor"), selectedImage: UIImage(named: "favor_1"))
        v5.tabBarItem = ESTabBarItem.init(TabBasicContentView(), title: "Me", image: UIImage(named: "me"), selectedImage: UIImage(named: "me_1"))
        
        tabBarController.viewControllers = [v1, v2, v3, v4, v5]
        
        let navigationController = BasicNavigationController.init(rootViewController: tabBarController)
        tabBarController.title = "Feed"
        return navigationController
    }
}
