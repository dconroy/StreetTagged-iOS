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
import MapKit
import Eureka
import Lightbox
import Photos

public class UploadArtController: FormViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    let loading = LoadingView()
    var imageRow: ImageRow?
    var editRow: ButtonRow?
    var locationRow: LocationRow?
    var arttitle: String = ""
    var artist: String = ""
    var artdescription: String = ""
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
        
    public var image: UIImage?
    public var imageLocation: CLLocation?
    
    deinit {
        timer.invalidate()
    }
    
    func startSubmitting() {
        getUserAWSAccessToken (completionHandler: { (token) in
            var coordinates: [String : Any]?
            
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
                "tags": self.artdescription.hashTags(),
                "token": token!,
                "about": self.artdescription,
                "isActive":  !self.needsModeration
            ]
            Alamofire.request(postItemURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                   if(self.needsModeration){
                       let alert = UIAlertController(title: "Success!", message: "Your art was submitted, but requires further review. Please check back soon.", preferredStyle: UIAlertController.Style.alert)
                       alert.addAction(UIAlertAction(title: "Got it!", style: UIAlertAction.Style.cancel, handler: { (alert: UIAlertAction!) in
                           self.dismiss(animated: true, completion: nil)
                       }))
                       self.present(alert, animated: true, completion: nil)
                   } else {
                        self.loading.hide()
                        refreshPosts()
                        self.dismiss(animated: true, completion: nil)
                   }
               }
        })
    }
    
    func startProcessing() {
        let modParameters: [String : Any] = [
            "bucket": s3Bucket,
            "name": self.imageFilename
        ]
        self.needsModeration = false
        Alamofire.request(moderationTagsURL, method: .post, parameters: modParameters, encoding: JSONEncoding.default).responseJSON { response in
            do {
                let decoder = JSONDecoder()
                let moderationLabels = try decoder.decode(ModerationLabels.self, from: response.data!)
                self.moderationTags = moderationLabels.data
                for moderationLabel in moderationLabels.data {
                    print(moderationLabel)
                    self.needsModeration = true
                }
                self.moderationComplete = true
            } catch let error {
                print(error.localizedDescription)
                self.moderationComplete = true
            }
            
            self.loading.setTitle(text: "Submitting");
            self.startSubmitting();
        }
    }
    
    @objc func post() {
        loading.show(view: view,color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        loading.setTitle(text: "Upload...");
        navigationItem.rightBarButtonItem?.isEnabled = false;
        var isCompleted = false;
        if (userGlobalState == .userSignedIn) {
            let filter = "1080x1080"
            uploadUIImageToAWSS3(image: image!, progressHandler: { (progress) in
                if (progress.fractionCompleted == 1.0 && !isCompleted) {
                    isCompleted = true
                    self.loading.setTitle(text: "Processing");
                    self.startProcessing()
                } else {
                    if (!isCompleted) {
                        self.loading.setTitle(text: "Upload..." + String(format: "%.2f", (progress.fractionCompleted * 100)) + "%");
                    }
                }
            }, statusHandler: { (task, key) in
                if let _ = task.result {
                    if (key?.isEmpty == false  && filter.isEmpty == false) {
                        let imageURL: String = imageURLFromS3Key(key: key!,filter: filter)
                        print(imageURL)
                        self.imageLink = imageURL
                        self.imageFilename = key!
                    }
                    
                }
            })
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
            if (asset.location != nil) {
                imageLocation = asset.location
            } else {
                imageLocation = globalLocation
            }
        }
        
        self.image = image
        self.imageRow!.reload()
        self.editRow!.reload()
        self.locationRow!.reload()
        navigationItem.rightBarButtonItem?.isEnabled = true;
        self.dismiss(animated: true, completion: nil)
    }
    
    func selectImage() {
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
    
    override public func viewDidLoad() {
        super.viewDidLoad()
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
        
        self.locationRow = LocationRow(){
            $0.title = "Art Location"
            $0.value = globalLocation
        }.cellUpdate { ps, row in
            if (self.imageLocation != nil) {
                row.value = self.imageLocation
            } else {
                row.value = globalLocation
            }
        }.onChange { row in
            self.imageLocation = row.value!
            self.locationRow?.reload()
        }
                
        // Form building
        form
        +++ Section(header: "Artwork (Step #1)", footer: "Once you are done with your submission of artwork, you can tap on the art above to get a preview on the piece after it has been approved.")
            <<< self.imageRow!
            
        +++ Section(header: "Image Options", footer: "")
            <<< ButtonRow(){ row in
                row.title = "Re-Select Image"
                row.onCellSelection { cell, row in
                    self.selectImage()
                }
            }
            <<< self.editRow!
        +++ Section(header: "General Details (Step #2)", footer: "General details about the piece allow us to index quickly and create custom feeds.")
            /*<<< TextRow(){ row in
                row.title = "Title"
                row.placeholder = "if known"
            }.onChange { row in
                self.arttitle = row.value!
            }*/
            <<< TextRow(){ row in
                row.title = "Artist"
                row.placeholder = "if known"
            }.onChange { row in
                if (row.value != nil) {
                    self.artist = row.value!
                }
            }
            <<< TextAreaRow(){
                $0.title = "Description"
                $0.placeholder = "description - if available"
            }.onChange { row in
                if (row.value != nil) {
                    self.artdescription = row.value!
                }
            }
        +++ Section(header: "Geolocation (Step #3)", footer: "An accurate location allows us to provide the community reliable directions to find this artwork with ease.")
            <<< self.locationRow!
        
        
        selectImage()
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
        navigationItem.rightBarButtonItem?.isEnabled = true;
    }
  
    public func pixelEditViewControllerDidCancelEditing(in controller: PixelEditViewController) {
    self.navigationController?.popToViewController(self, animated: true)
  }
  
}
