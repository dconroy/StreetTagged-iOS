//
//  AppDelegate.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 9/12/19.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import UIKit
import CoreData
import ESTabBarController_swift
import AWSMobileClient
import AWSS3

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        userStateInitialize(enabledLogs: true, responder: self)
                
        let storyboard: UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
    
        let profile = storyboard.instantiateViewController(withIdentifier: "Profile") as! ProfileController
        
        let flow = UICollectionViewFlowLayout()
        let v1 = FeedController(collectionViewLayout: flow)
        let v2 = NearByController()
        let v3 = FavorController()
        let v4 = FavorController()
        let v5 = profile
        
        
        
        let tabBarController = ESTabBarController()
        tabBarController.delegate = self
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
                    let vc = storyboard.instantiateViewController(withIdentifier: "UploadArt") as! UploadArtController
                    tabBarController?.viewControllers![0].present(vc, animated: true, completion: nil)
                   }
        }
               
               
        v1.tabBarItem = ESTabBarItem.init(TabBasicContentView(), title: "Feed", image: UIImage(named: "home"), selectedImage: UIImage(named: "home_1"))
        v2.tabBarItem = ESTabBarItem.init(TabBasicContentView(), title: "Nearby", image: UIImage(named: "find"), selectedImage: UIImage(named: "find_1"))
        v3.tabBarItem = ESTabBarItem.init(TabContentView(), title: nil, image: UIImage(named: "photo_verybig"), selectedImage: UIImage(named: "photo_verybig"))
        v4.tabBarItem = ESTabBarItem.init(TabBasicContentView(), title: "Favorites", image: UIImage(named: "favor"), selectedImage: UIImage(named: "favor_1"))
        v5.tabBarItem = ESTabBarItem.init(TabBasicContentView(), title: "Me", image: UIImage(named: "me"), selectedImage: UIImage(named: "me_1"))
               
        tabBarController.viewControllers = [v1, v2, v3, v4, v5]
               
        let navigationController = BasicNavigationController.init(rootViewController: tabBarController)
        tabBarController.title = "Feed"
        
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "StreetTagged")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

