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
import Photos
import CoreLocation
import GetStream

var globalLatitude: CLLocationDegrees?
var globalLongitude: CLLocationDegrees?
var globalLocation: CLLocation = CLLocation.init()

var hasGlobalGPS: Bool = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    
    var currentViewController: UIViewController?
    let storyboard: UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
    let locationManager = CLLocationManager()
    
    let getStreamVC = GetStreamViewController()
    
    var getStreamFollers: [Follower] = []
    
    func setGetStreamFollowers(follower: [Follower]) {
        getStreamFollers = follower
    }
    
    func getGetStreamFollowers() -> [Follower] {
        return getStreamFollers
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("location manager authorization status changed")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: GLOBAL_POSTS_REFRESHED), object: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            globalLatitude = location.coordinate.latitude
            globalLongitude = location.coordinate.longitude
            globalLocation = location
            hasGlobalGPS = true
        }
    }
    
    @objc func timerGPSFunction() {
        
    }
    
    func updateGetStream(name: String, id: String, token: String) {
        Client.shared.setupUser(User(name: name,  id: id), token: token) { (result) in
            self.getStreamVC.updateSetup()
            self.getStreamVC.reloadData()
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // TODO: Refactor the cube storage
        ColorCubeStorage.loadToDefault()
                
        Client.config = .init(apiKey: UIApplication.getStreamApiKey!, appId: UIApplication.getStreamAppId!, logsEnabled: false)
        
        userStateInitialize(enabledLogs: true, responder: self)
            
        let nearByVC = NearByController()
        let blankVC = UIViewController()
        let favorVC = FavorController()
        let profileVC = storyboard.instantiateViewController(withIdentifier: "Profile") as! ProfileController
        
        currentViewController = getStreamVC
                
        let tabBarController = ESTabBarController()
        tabBarController.delegate = self
        tabBarController.title = ""
        tabBarController.tabBar.shadowImage = UIImage(named: "transparent")
        tabBarController.tabBar.backgroundImage = UIImage(named: "background")
        tabBarController.shouldHijackHandler = {
        tabbarController, viewController, index in
                if index == 2 {
                    return true
                }
                self.currentViewController = viewController

                if index == 0 {
                    tabBarController.title = "For You"
                }
                if index == 1 {
                    tabBarController.title = "Nearby"
                }
                if index == 3 {
                    if (userGlobalState == .userSignedIn) {
                        tabBarController.title = "Favorites"
                    } else {
                        return true
                    }
                }
                if index == 4 {
                    tabBarController.title = "Me"
                }
                return false
        }
        tabBarController.didHijackHandler = { tabbarController, viewController, index in
                if index == 2 {
                    if (userGlobalState == .userSignedIn) {
                        let vc = UploadArtController()
                        let navigationController = UINavigationController(rootViewController: vc)
                        navigationController.modalPresentationStyle = .fullScreen
                        self.currentViewController!.dismiss(animated: true, completion: nil)
                        self.currentViewController!.present(navigationController, animated: true, completion: nil)
                    } else {
                        let alert = UIAlertController(title: "Are you logged in?", message: "Please sign in or create an account to submit and favorite street art.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Sign In/Sign Up", style: UIAlertAction.Style.default, handler: { (alert: UIAlertAction!) in
                            userSignIn(navController: self.currentViewController!.navigationController!)
                        }))
                        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (alert: UIAlertAction!) in
                            
                        }))
                        self.currentViewController!.present(alert, animated: true, completion: nil)
                    }
                }
                if index == 3 {
                    if (userGlobalState == .userSignedIn) {
                    
                    } else {
                        let alert = UIAlertController(title: "Are you logged in?", message: "Please sign in or create an account to submit and favorite street art.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Sign In/Sign Up", style: UIAlertAction.Style.default, handler: { (alert: UIAlertAction!) in
                            userSignIn(navController: self.currentViewController!.navigationController!)
                        }))
                        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (alert: UIAlertAction!) in
                            
                        }))
                        self.currentViewController!.present(alert, animated: true, completion: nil)
                    }
                }
        }
               
        getStreamVC.tabBarItem = ESTabBarItem.init(TabBasicContentView(), title: "For You", image: UIImage(named: "home"), selectedImage: UIImage(named: "home_1"))
        nearByVC.tabBarItem = ESTabBarItem.init(TabBasicContentView(), title: "Nearby", image: UIImage(named: "find"), selectedImage: UIImage(named: "find_1"))
        blankVC.tabBarItem = ESTabBarItem.init(TabContentView(), title: nil, image: UIImage(named: "photo_verybig"), selectedImage: UIImage(named: "photo_verybig"))
        favorVC.tabBarItem = ESTabBarItem.init(TabBasicContentView(), title: "Favorites", image: UIImage(named: "favor"), selectedImage: UIImage(named: "favor_1"))
        profileVC.tabBarItem = ESTabBarItem.init(TabBasicContentView(), title: "Me", image: UIImage(named: "me"), selectedImage: UIImage(named: "me_1"))
               
        tabBarController.viewControllers = [getStreamVC, nearByVC, blankVC, favorVC, profileVC]
               
        let navigationController = BasicNavigationController.init(rootViewController: tabBarController)
        tabBarController.title = "For You"
        
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        NotificationCenter.default.addObserver(self, selector: #selector(startLocationManager), name: NSNotification.Name(rawValue: GLOBAL_START_LOCATION_MANAGER), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(areYouLoggedIn), name: NSNotification.Name(rawValue: GLOBAL_ARE_YOU_LOGGED_IN), object: nil)
          
        return true
    }
    
    @objc func areYouLoggedIn() {
        let alert = UIAlertController(title: "Are you logged in?", message: "Please sign in or create an account to submit and favorite street art.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Sign In/Sign Up", style: UIAlertAction.Style.default, handler: { (alert: UIAlertAction!) in
            userSignIn(navController: self.currentViewController!.navigationController!)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (alert: UIAlertAction!) in
            
        }))
        self.currentViewController!.present(alert, animated: true, completion: nil)
    }
    
    @objc func startLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    @objc func toggle() {
        globalSimpleMode = !globalSimpleMode
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: GLOBAL_POSTS_REFRESHED), object: nil)
    }
    
    func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            imagePickerController.modalPresentationStyle = .fullScreen
            imagePickerController.allowsEditing = true
            self.currentViewController!.present(imagePickerController, animated: true, completion: nil)
        }
    }
        
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        //let vc = storyboard.instantiateViewController(withIdentifier: "UploadArt") as! UploadArtController
        let vc = UploadArtController()
        vc.image = image
        
        if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
            vc.imageLocation = asset.location
        }           
                
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        self.currentViewController!.dismiss(animated: true, completion: nil)
        self.currentViewController!.present(navigationController, animated: true, completion: nil)
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

