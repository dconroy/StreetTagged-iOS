//
//  ViewController.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 9/12/19.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import UIKit
import Alamofire
import AWSCore
import AWSMobileClient
import AWSS3

import CoreLocation
import UserNotifications

struct Art: Decodable {
    let artId: String
    let username: String
    let tags: [String]
    let picture: String
    let about: String
    var isFavorited: Bool?
    let location: Location
    let createdAt: String
}

struct Location: Decodable {
    let type: String
    let coordinates: [Float]
}

struct ArtWorks: Decodable {
    let items: [Art]
}

struct GetStreamTokenResponse: Decodable {
    let userToken: String
}

struct ModerationLabel: Decodable {
    let Confidence: Double
    let Name: String
    let ParentName: String
}

struct ModerationLabels: Decodable {
    let data: [ModerationLabel]
 }

struct FavoriteArtWorks: Decodable {
    let artWorks: [Art]
}

struct TagsRespsonse: Decodable {
    let tags: [String]
}

struct ArtWorkReview: Decodable {
    let item: [Art]
}

struct Headline {
    
    var id : Int
    var title : String
    var text : String
    var image : String
    
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var progressBar: UIProgressView!
       
    let textCellIdentifier = "TextCell"
    var items: [Art] = []
    let imageCache = NSCache<NSString, UIImage>()
    
    var imageLink = ""
    let center = UNUserNotificationCenter.current()
    let locationManager = CLLocationManager()
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        locationManager.delegate = self
    }
    
    @IBAction func selectImageFromGallery(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = image
        let filter = "1080x1080"
        
        if (userGlobalState == .userSignedIn) {
            uploadUIImageToAWSS3(image: image, progressHandler: { (progress) in
                print("uploadUIImageToAWSS3-Process: \(progress)")
                self.progressBar.progress = Float(progress.fractionCompleted)
            }, statusHandler: { (task, key) in
                if (key?.isEmpty == false && filter.isEmpty == false) {
                    let imageURL: String = imageURLFromS3Key(key: key!, filter: filter)
                    self.imageLink = imageURL
                    print(imageURL)
                }
                if let _ = task.result {
                    
                }
            })
        } else {
            print("Please sign in to upload an image")
        }
        dismiss(animated: true, completion: nil)
    }
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        
        let row = indexPath.row
        cell.textLabel?.text = items[row].picture
        
        Alamofire.request(items[row].picture).response { response in
            if let data = response.data {
                let image = UIImage(data: data)
                cell.imageView!.image = image
            } else {

            }
        }
        
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        print(items[row].artId)
    }
    
    
    // MARK: ViewController
    @IBAction func showSignIn(_ sender: UIButton, forEvent event: UIEvent){
        //userSignInWithCreds(username: "", password: "")
        userSignIn(navController: self.navigationController!)
    }
    
    @IBAction func signOut(_ sender: UIButton, forEvent event: UIEvent){
        userSignOut()
    }
    
    @IBAction func reviewArt(_ sender: UIButton, forEvent event: UIEvent){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReviewView") as! ReviewArtWork
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func getUser(_ sender: UIButton, forEvent event: UIEvent){
        getUserAWSAccessToken (completionHandler: { (token) in
            print(token)
        })
    }
    
    @IBAction func getGPS(_ sender: UIButton, forEvent event: UIEvent){
        print("getGPS")
        locationManager.requestWhenInUseAuthorization()
        //locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("location manager authorization status changed")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // might be that user didn't enable location service on the device
        // or there might be no GPS signal inside a building
      
        // might be a good idea to show an alert to user to ask them to walk to a place with GPS signal
        
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // .requestLocation will only pass one location to the locations array
        // hence we can access it by taking the first element of the array
        if let location = locations.first {
            print(location.coordinate.latitude)
            print(location.coordinate.longitude)
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
        }
    }
    
    @IBAction func postArt(_ sender: UIButton, forEvent event: UIEvent){
        print("postArt")
        if (userGlobalState == .userSignedIn) {
            getUserAWSAccessToken (completionHandler: { (token) in
                let parameters: [String : Any] = [
                    "coordinates": [
                        "latitude": self.latitude!,
                        "longitude": self.longitude!
                    ],
                    "picture": self.imageLink,
                    "token": token!
                ]
                
                print(parameters)
                
                Alamofire.request("https://api-dev.streettagged.com/items", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                    
                    do {
                        print(response)
                    } catch let error {
                        print(error)
                    }
                    
                }
            })
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    @IBAction func getArtWork(_ sender: UIButton, forEvent event: UIEvent){
        print("getArtWork")
        AWSMobileClient.default().getTokens { (tokens, error) in
            if let error = error {
                print("Error getting token \(error.localizedDescription)")
            } else if let tokens = tokens {
                print(tokens.accessToken!.tokenString!)
                
                let parameters = [
                    "token": tokens.accessToken!.tokenString!
                ]
                
                /*let headers = [
                    "Content-Type": "application/json"
                ]*/
                
                print(parameters)
                
                Alamofire.request("https://api-dev.streettagged.com/items/search", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                    
                    do {
                        let decoder = JSONDecoder()
                        let artWorks = try decoder.decode(ArtWorks.self, from: response.data!)
                        print(artWorks)
                        for art in artWorks.items {
                            print("========================================================")
                            print(art.artId)
                            print(art.username)
                            print(art.isFavorited)
                            print(art.tags)
                            print(art.location)
                            print(art.picture)
                        }
                        self.items = artWorks.items
                        self.tableView.reloadData()
                    } catch let error {
                        print(error)
                    }
                    
                }
                
            }
        }
        
    }

}

