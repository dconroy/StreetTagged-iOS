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

class FavorController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var images = [Post]()
    var isShowingImage: Bool = false
    
    var favoriteCollectionView:UICollectionView?
    
    public override func viewDidAppear(_ animated: Bool) {
        favoriteStreetList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(favoriteNotification), name: NSNotification.Name(rawValue: GLOBAL_FAVS_REFRESHED), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: GLOBAL_START_LOCATION_MANAGER), object: nil)
    }
    
    @objc func favoriteNotification() {
        //loadListOfImages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 90, height: 90)
        
        favoriteCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        favoriteCollectionView!.dataSource = self
        favoriteCollectionView!.delegate = self
        favoriteCollectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "favCell")
        favoriteCollectionView!.backgroundColor = UIColor.white
        self.view.addSubview(favoriteCollectionView!)
        
        loadListOfImages()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
 
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let favCell = collectionView.dequeueReusableCell(withReuseIdentifier: "favCell", for: indexPath as IndexPath)
        favCell.backgroundColor = UIColor.black
        
        let post = self.images[indexPath.row]
        
        let imageView = UIImageView(frame: CGRect(x:0, y:0, width:favCell.frame.size.width, height:favCell.frame.size.height))
        
        
        imageView.loadImage(post.image)
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        favCell.addSubview(imageView)
        
        return favCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if (!isShowingImage) {
            let post: Post = self.images[indexPath.row]
            isShowingImage = true
            let images = [
             LightboxImage(
                imageURL: URL(string: post.image)!,
               text: post.about
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
    
    
    func loadListOfImages()
    {
        self.images = favoritePosts
        
        DispatchQueue.main.async {
            self.favoriteCollectionView!.reloadData()
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
