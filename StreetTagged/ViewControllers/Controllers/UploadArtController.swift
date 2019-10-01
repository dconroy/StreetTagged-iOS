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
import WSTagsField
import MapKit

public class UploadArtController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
       
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var textView: UITextView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var imageLink = ""
    var tags: [String] = []
    let center = UNUserNotificationCenter.current()
    let locationManager = CLLocationManager()
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    
    var hasImage: Bool = false
    var hasGPS: Bool = false
    var timer = Timer()

    let regionRadius: CLLocationDistance = 1000
    
    public var image: UIImage?
    
    fileprivate let tagsField = WSTagsField()
    @IBOutlet fileprivate weak var tagsView: UIView!
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
      timer.invalidate()
    }
    
    @objc func post() {
        navigationItem.rightBarButtonItem?.isEnabled = false;
        if (hasImage && hasGPS) {
            if (userGlobalState == .userSignedIn) {
                getUserAWSAccessToken (completionHandler: { (token) in
                    let parameters: [String : Any] = [
                        "coordinates": [
                            "latitude": self.latitude!,
                            "longitude": self.longitude!
                        ],
                        "picture": self.imageLink,
                        "tags": self.tags,
                        "token": token!
                    ]                                    
                    Alamofire.request(postItemURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                        print(response)
                        let alert = UIAlertController(title: "Your art was submitted!", message: "As part of the review your submission is going to be review which could take up to 24 hours. Once reviewed it will appear on the global and local feeds.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Got it!", style: UIAlertAction.Style.cancel, handler: { (alert: UIAlertAction!) in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        } else {
            let alert = UIAlertController(title: "Could not submit", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (alert: UIAlertAction!) in
                                       
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func cancel() {
        let alert = UIAlertController(title: "Are you sure?", message: "If you discard your art work post you cannot recovor it. Are you sure you like to discard it?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (alert: UIAlertAction!) in
        }))
        alert.addAction(UIAlertAction(title: "Yes, Discard", style: UIAlertAction.Style.destructive, handler: { (alert: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func timerAction() {
        if (self.hasImage == true && self.hasGPS == true && self.progressBar.progress == 1.0) {
            navigationItem.rightBarButtonItem?.isEnabled = true;
        }
        if (self.progressBar.progress == 1.0) {
            self.progressBar.isHidden = true
        }
    }
        
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Upload Street Art"
        
        let cancelItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        let postItem = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(post))

        navigationItem.rightBarButtonItem = postItem
        navigationItem.leftBarButtonItem = cancelItem
        navigationItem.rightBarButtonItem?.isEnabled = false;
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
        self.imageView.image = image!
        if (userGlobalState == .userSignedIn) {
            uploadUIImageToAWSS3(image: image!, progressHandler: { (progress) in
                self.progressBar.progress = Float(progress.fractionCompleted)
            }, statusHandler: { (task, key) in
                if let _ = task.result {
                    if (key?.isEmpty == false) {
                        let imageURL: String = imageURLFromS3Key(key: key!)
                        self.imageLink = imageURL
                        self.hasImage = true
                        print(imageURL)
                    }
                }
            })
        }
        
        
        tagsField.frame = tagsView.bounds
        tagsView.addSubview(tagsField)

        tagsField.cornerRadius = 5.0
        tagsField.spaceBetweenLines = 10
        tagsField.spaceBetweenTags = 10

        tagsField.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tagsField.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        tagsField.placeholder = "Enter some tags"
        tagsField.placeholderColor = .black
        tagsField.placeholderAlwaysVisible = true
        tagsField.backgroundColor = .clear
        tagsField.returnKeyType = .continue
        tagsField.delimiter = ""

        tagsField.textDelegate = self
        
        tagsField.onDidAddTag = { field, tag in
            self.tags.append(tag.text)
        }

        tagsField.onDidRemoveTag = { field, tag in
            if let index = self.tags.firstIndex(of: tag.text) {
                self.tags.remove(at: index)
            }
        }

        tagsField.onDidChangeText = { _, text in }

        tagsField.onDidChangeHeightTo = { _, height in }

        tagsField.onValidateTag = { tag, tags in
            return tag.text != "#" && !tags.contains(where: { $0.text.uppercased() == tag.text.uppercased() })
        }
        
        textView.becomeFirstResponder()
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
            self.hasGPS = true
            centerMapOnLocation(location: location)
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
    let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
      mapView.setRegion(coordinateRegion, animated: true)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
}

extension UploadArtController: UITextFieldDelegate {

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tagsField {

        }
        return true
    }

}
