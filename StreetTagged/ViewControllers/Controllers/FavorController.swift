//
//  FavorController.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 9/13/19.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//
import UIKit
import Foundation

public class FavorController: UIViewController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 244.0 / 255.0, green: 245.0 / 255.0, blue: 245.0 / 255.0, alpha: 1.0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(favoriteNotification), name: NSNotification.Name(rawValue: GLOBAL_FAVS_REFRESHED), object: nil)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        favoriteStreetList()
    }
    
    @objc func favoriteNotification() {
        print("favoriteNotification")
        print(favoritePosts.count)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
}
