//
//  FavorController.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 9/13/19.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//
import UIKit
import Foundation
import Lightbox
import GetStream
import AWSMobileClient

class FavorController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var activities = [Activity]()
    var isShowingImage: Bool = false
    
    var favoriteCollectionView:UICollectionView?
    
    public override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 90, height: 90)
        
        favoriteCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        favoriteCollectionView!.dataSource = self
        favoriteCollectionView!.delegate = self
        favoriteCollectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "favCell")
        favoriteCollectionView!.backgroundColor = UIColor.white
        self.view.addSubview(favoriteCollectionView!)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: GLOBAL_START_LOCATION_MANAGER), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AWSMobileClient.default().initialize({ (state, error) in
            switch (state) {
                case .signedIn:
                    Client.shared.reactions(forUserId: AWSMobileClient.default().username!, completion: { result in
                        let reactions = try! result.get()
                        
                        print(reactions)
                        
                        let ids = reactions.reactions.map { $0.activityId }

                        
                        Client.shared.get(typeOf: Activity.self, activityIds: ids, completion: { rr in
                            let activities = try! rr.get()
                            
                            self.activities = activities.results.sorted(by: {
                                $0.time!.compare($1.time!) == .orderedDescending
                            })
                            
                            DispatchQueue.main.async {
                                self.favoriteCollectionView!.reloadData()
                            }
                        });
                    })
                default:
                    userGlobalState = .userStateUnknown
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.activities.count
    }
 
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let favCell = collectionView.dequeueReusableCell(withReuseIdentifier: "favCell", for: indexPath as IndexPath)
        favCell.backgroundColor = UIColor.black
        
        let post = self.activities[indexPath.row]
        
        let imageView = UIImageView(frame: CGRect(x:0, y:0, width:favCell.frame.size.width, height:favCell.frame.size.height))
        
        switch post.object {
            case .imageText(let url, let value, let location):
                    imageView.kf.setImage(with: url)
            default:
                    break
        }
        
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        favCell.addSubview(imageView)
        return favCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if (!isShowingImage) {
            let post: Activity = self.activities[indexPath.row]
            switch post.object {
                case .imageText(let url, let value, let location):
                    isShowingImage = true
                    let images = [
                     LightboxImage(
                        imageURL: url,
                        text: value
                     ),
                    ]

                    let controller = LightboxController(images: images)
                    controller.pageDelegate = self
                    controller.dismissalDelegate = self

                    controller.dynamicBackground = true
                    controller.modalPresentationStyle = .fullScreen
                    
                    self.present(controller, animated: true, completion: nil)
                default:
                    break
            }
        }
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension FavorController: LightboxControllerPageDelegate {
  func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) { }
}

extension FavorController: LightboxControllerDismissalDelegate {

  func lightboxControllerWillDismiss(_ controller: LightboxController) {
    isShowingImage = false
  }
}
