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
import Eureka

public class UploadArtController: FormViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var textView: UITextView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var imageLink = ""
    var imageFilename = ""
    var tags: [String] = []
    var moderationTags: [ModerationLabel] = []
    let center = UNUserNotificationCenter.current()
    
    var hasImage: Bool = false
    var moderationComplete: Bool = false
    var moderationPending: Bool = false
    var needsModeration: Bool = true
    var timer = Timer()
    
    let regionRadius: CLLocationDistance = 1000
    
    public var image: UIImage?
    
    public var imageLocation: CLLocation?
    
    fileprivate let tagsField = WSTagsField()
    @IBOutlet fileprivate weak var tagsView: UIView!
    
    /*required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }*/
    
    deinit {
        timer.invalidate()
    }
    
    @objc func post() {
        navigationItem.rightBarButtonItem?.isEnabled = false;
        if (hasImage && hasGlobalGPS) {
            if (userGlobalState == .userSignedIn) {
                let about: String = self.textView.text!
                getUserAWSAccessToken (completionHandler: { (token) in
                    var coordinates: [String : Any]?
                    
                    //if moderation tags = null, seet is active to true
                    if self.imageLocation != nil {
                        coordinates = [
                            "latitude": self.imageLocation!.coordinate.latitude,
                            "longitude": self.imageLocation!.coordinate.longitude
                        ]
                    } else {
                        coordinates = [
                            "latitude": globalLatitude!,
                            "longitude": globalLongitude!
                        ]
                    }
                    let parameters: [String : Any] = [
                        "coordinates": coordinates! as Any,
                        "picture": self.imageLink,
                        "tags": about.hashtags(),
                        "token": token!,
                        "about": about,
                        "isActive":  !self.needsModeration
                    ]
                    Alamofire.request(postItemURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                 
                        
                        if(self.needsModeration){
                            
                            let alert = UIAlertController(title: "Success!", message: "Your art was submitted, but requires further review. Please check back soon.", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Got it!", style: UIAlertAction.Style.cancel, handler: { (alert: UIAlertAction!) in
                                self.dismiss(animated: true, completion: nil)}))
                            self.present(alert, animated: true, completion: nil)
                            
                        } else {
                            let alert = UIAlertController(title: "Success!", message: "Your art was submitted!", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Got it!", style: UIAlertAction.Style.cancel, handler: { (alert: UIAlertAction!) in
                                self.dismiss(animated: true, completion: nil)
                            }))
                            self.present(alert, animated: true, completion: nil)
                            refreshPosts()
                            
                        }
                        
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
        let alert = UIAlertController(title: "Are you sure?", message: "If you discard your art work post you cannot recover it. Are you sure you'd like to discard it?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (alert: UIAlertAction!) in
        }))
        alert.addAction(UIAlertAction(title: "Yes, Discard", style: UIAlertAction.Style.destructive, handler: { (alert: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func timerAction() {
        if (self.hasImage == true && hasGlobalGPS == true && self.moderationComplete == true && self.progressBar.progress == 1.0) {
            navigationItem.rightBarButtonItem?.isEnabled = true;
        }
        
        if (self.progressBar.progress == 1.0 && self.moderationPending == false) {
            //only call moderation endpoint once
            moderationPending = true
            
            let modParameters: [String : Any] = [
                "bucket": s3Bucket,
                "name": imageFilename
                //"name": "1840_burnt-orange2.jpg"  //use this line to force a moderation label
            ]
            
            print(modParameters)
            
            Alamofire.request(moderationTagsURL, method: .post, parameters: modParameters, encoding: JSONEncoding.default).responseJSON { response in
                do {
                    print(response)
                    
                    let decoder = JSONDecoder()
                    let moderationLabels = try decoder.decode(ModerationLabels.self, from: response.data!)
                    self.moderationTags = moderationLabels.data
                    self.needsModeration = false
                    
                    print(moderationLabels)
                    //if we find a moderation label, set needsModeration to true
                    
                    for moderationLabel in moderationLabels.data {
                        print(moderationLabel)
                        self.needsModeration = true
                    }
                    
                    self.moderationComplete = true
                    
                } catch let error {
                    print(error.localizedDescription)
                    self.moderationComplete = true
                }
            }
        }
        
        //keep progress bar up until moderation check is complete now
        if (self.progressBar.progress == 1.0 && self.moderationComplete == true) {
            self.progressBar.isHidden = true
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Navigation controls
        let filter = "1080x1080"
        self.title = "Upload Street Art"
        
        let cancelItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        let postItem = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(post))
        
        navigationItem.rightBarButtonItem = postItem
        navigationItem.leftBarButtonItem = cancelItem
        navigationItem.rightBarButtonItem?.isEnabled = false;
        
        // Form building
        form
        +++ Section("Art Work")
            <<< CustomRow() { row in
                
            }
        +++ Section("General Details")
            <<< TextRow(){ row in
                row.title = "Name"
                row.placeholder = ""
            }
            <<< TextRow(){ row in
                row.title = "Artist"
                row.placeholder = "if known"
            }
            <<< TextAreaRow(){
                $0.title = "Description"
                $0.placeholder = "description"
            }
        +++ Section("Geolocation")
            <<< LocationRow(){
                $0.title = "LocationRow"
                $0.value = CLLocation(latitude: -34.91, longitude: -56.1646)
            }
        +++ MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete],
                           header: "Tags",
                           footer: "Please tag this peice of street art. Your honest input helps StreetTagged train AI models to give the art community a better overall experience") {
            $0.addButtonProvider = { section in
                return ButtonRow(){
                    $0.title = "Add New Tag"
                }
            }
            $0.multivaluedRowToInsertAt = { index in
                return NameRow() {
                    $0.placeholder = "Tag Name"
                }
            }
        }
    }
    
    /*
    override public func viewDidLoad() {
        super.viewDidLoad()
        let filter = "1080x1080"
        self.title = "Upload Street Art"
        
        let cancelItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        let postItem = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(post))
        
        navigationItem.rightBarButtonItem = postItem
        navigationItem.leftBarButtonItem = cancelItem
        navigationItem.rightBarButtonItem?.isEnabled = false;
        
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
        self.imageView.image = image!
        if (userGlobalState == .userSignedIn) {
            uploadUIImageToAWSS3(image: image!, progressHandler: { (progress) in
                self.progressBar.progress = Float(progress.fractionCompleted)
            }, statusHandler: { (task, key) in
                if let _ = task.result {
                    if (key?.isEmpty == false  && filter.isEmpty == false) {
                        let imageURL: String = imageURLFromS3Key(key: key!,filter: filter)
                        self.imageLink = imageURL
                        self.imageFilename = key!
                        self.hasImage = true
                        print(imageURL)
                    }
                    
                }
            })
        }
        
        
        textView.becomeFirstResponder()
        
        if self.imageLocation != nil {
            self.centerMapOnLocation(location: self.imageLocation!)
        } else {
            self.centerMapOnLocation(location: globalLocation)
        }
    }*/
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        mapView.addAnnotation(annotation)
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

extension String
{
    func hashtags() -> [String]
    {
        if let regex = try? NSRegularExpression(pattern: "#[a-z0-9]+", options: .caseInsensitive)
        {
            let string = self as NSString
            
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range).lowercased()
            }
        }
        
        return []
    }
}
