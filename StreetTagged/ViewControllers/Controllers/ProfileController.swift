//
//  ProfileController.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 9/13/19.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//
import UIKit
import Foundation
import Alamofire
import AWSMobileClient

public class ProfileController: UIViewController {
    
    @IBOutlet var mainButton: UIButton!
    @IBOutlet var usernameLabel: UILabel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 244.0 / 255.0, green: 245.0 / 255.0, blue: 245.0 / 255.0, alpha: 1.0)
        switch userGlobalState {
        case .userSignedIn:
            self.mainButton.setTitle("Sign Out", for: UIControl.State.normal)
            self.usernameLabel.text = AWSMobileClient.default().username
            self.usernameLabel.isHidden = false
            break
        default:
            self.mainButton.setTitle("Sign In", for: UIControl.State.normal)
            self.usernameLabel.isHidden = true
            break
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        switch userGlobalState {
        case .userSignedIn:
            self.mainButton.setTitle("Sign Out", for: UIControl.State.normal)
            self.usernameLabel.text = AWSMobileClient.default().username
            self.usernameLabel.isHidden = false
            break
        default:
            self.mainButton.setTitle("Sign In", for: UIControl.State.normal)
            self.usernameLabel.isHidden = true
            break
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @IBAction func reviewArt(_ sender: UIButton, forEvent event: UIEvent){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReviewView") as! ReviewArtWork
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func action(_ sender: UIButton, forEvent event: UIEvent){
        switch userGlobalState {
        case .userSignedIn:
            userSignOut()
            self.mainButton.setTitle("Sign In", for: UIControl.State.normal)
            self.usernameLabel.isHidden = true
            break
        default:
            userSignIn(navController: self.navigationController!)
            self.mainButton.setTitle("Sign Out", for: UIControl.State.normal)
            self.usernameLabel.isHidden = false
            break
        }

    }
}
