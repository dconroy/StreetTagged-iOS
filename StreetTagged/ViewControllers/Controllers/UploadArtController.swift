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
import Lightbox
import Photos

public class UploadArtController: FormViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var textView: UITextView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var imageRow: ImageRow?
    var editRow: ButtonRow?
    
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
        let alert = UIAlertController(title: "Are you sure?", message: "If you discard your art work post you cannot recover it. Are you sure you'd like to discard it?", preferredStyle: UIAlertController.Style.actionSheet)
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
    
    func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            imagePickerController.modalPresentationStyle = .fullScreen
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
            print(asset)
        }
        
        
        self.image = image
        self.imageRow!.reload()
        self.editRow!.reload()
        self.dismiss(animated: true, completion: nil)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Navigation controls
        //let filter = "1080x1080"
        self.title = "Upload Street Art"
        
        let cancelItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        let postItem = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(post))
        
        navigationItem.rightBarButtonItem = postItem
        navigationItem.leftBarButtonItem = cancelItem
        navigationItem.rightBarButtonItem?.isEnabled = false;
        
        self.imageRow = ImageRow() { row in
            row.value = self.image
            row.onCellSelection { cell, row in
                if (self.image != nil) {
                    row.deselect()
                    
                    let images = [
                     LightboxImage(
                        image: self.image!,
                        text: ""
                     ),
                    ]

                    let controller = LightboxController(images: images)
                    controller.pageDelegate = self
                    controller.dismissalDelegate = self
                    controller.dynamicBackground = true
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }.cellUpdate { cell, row in
            row.value = self.image
        }
        
        self.editRow = ButtonRow(){ row in
            row.title = "Edit Image"
            row.onCellSelection { cell, row in
                if (self.image != nil) {
                    let controller = PixelEditViewController.init(image: self.image!)
                    controller.delegate = self
                    self.navigationController!.pushViewController(controller, animated: true)
                }
            }
        }
                
        // Form building
        form
        +++ Section(header: "Artwork (Step #1)", footer: "Once you are done with your submission of artwork, you can tap on the art above to get a preview on the piece after it has been approved.")
            <<< self.imageRow!
            
        +++ Section(header: "Image Options", footer: "")
            <<< ButtonRow(){ row in
                row.title = "Select Image"
                row.onCellSelection { cell, row in
                    let alert = UIAlertController(title: "Where would you like to select the image from?", message: "", preferredStyle: .actionSheet)
                    alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
                        self.getImage(fromSourceType: .camera)
                    }))
                    alert.addAction(UIAlertAction(title: "Photo Album", style: .default, handler: {(action: UIAlertAction) in
                        self.getImage(fromSourceType: .photoLibrary)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
                    self.navigationController!.present(alert, animated: true, completion: nil)
                }
            }
            <<< self.editRow!
        +++ Section(header: "General Details (Step #2)", footer: "General details about the piece allow us to index quickly and create custom feeds.")
            <<< TextRow(){ row in
                row.title = "Title"
                row.placeholder = "if known"
            }
            <<< TextRow(){ row in
                row.title = "Artist"
                row.placeholder = "if known"
            }
            <<< TextAreaRow(){
                $0.title = "Description"
                $0.placeholder = "description - if available"
            }
        +++ Section(header: "Geolocation (Step #3)", footer: "An accurate location allows us to provide the community reliable directions to find this artwork with ease.")
            <<< LocationRow(){
                $0.title = "Art Location"
                $0.value = globalLocation
            }
        /*+++ MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete],
                           header: "Tags (Step #4)",
                           footer: "Please tag this piece of street art. Your honest input helps StreetTagged train AI models to give the art community a better overall experience.") {
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
        }*/
        
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

extension UploadArtController: LightboxControllerPageDelegate {
    public func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) { }
}

extension UploadArtController: LightboxControllerDismissalDelegate {
    public func lightboxControllerWillDismiss(_ controller: LightboxController) {

  }
}

extension UploadArtController : PixelEditViewControllerDelegate {
  
    public func pixelEditViewController(_ controller: PixelEditViewController, didEndEditing editingStack: EditingStack) {
        self.navigationController?.popToViewController(self, animated: true)
        let image = editingStack.makeRenderer().render(resolution: .full)
        self.image = image
        self.imageRow!.reload()
    }
  
    public func pixelEditViewControllerDidCancelEditing(in controller: PixelEditViewController) {
    self.navigationController?.popToViewController(self, animated: true)
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
