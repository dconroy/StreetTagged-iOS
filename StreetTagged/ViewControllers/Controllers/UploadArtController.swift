//
//  UploadArtController.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 9/25/19.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import UIKit
import Alamofire
import AWSCore
import AWSMobileClient
import AWSS3

import CoreLocation
import UserNotifications

public class UploadArtController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
       
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var progressBar: UIProgressView!
    
    var imageLink = ""
    let center = UNUserNotificationCenter.current()
    let locationManager = CLLocationManager()
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = image
        locationManager.requestLocation()
        
        if (userGlobalState == .userSignedIn) {
            uploadUIImageToAWSS3(image: image, progressHandler: { (progress) in
                print("uploadUIImageToAWSS3-Process: \(progress)")
                self.progressBar.progress = Float(progress.fractionCompleted)
            }, statusHandler: { (task, key) in
                if (key?.isEmpty == false) {
                    let imageURL: String = imageURLFromS3Key(key: key!)
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
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("location manager authorization status changed")
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print(location.coordinate.latitude)
            print(location.coordinate.longitude)
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
        }
    }
    
    @IBAction func selectImageFromGallery(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
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
                        self.dismiss(animated: true, completion: nil)
                    } catch let error {
                        print(error)
                    }
                    
                }
            })
        }
    }
    
    @IBAction func dissmiss(_ sender: UIButton, forEvent event: UIEvent){
        self.dismiss(animated: true, completion: nil)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
}
