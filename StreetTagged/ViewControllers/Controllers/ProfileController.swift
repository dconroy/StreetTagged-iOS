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
   
        NotificationCenter.default.addObserver(self, selector: #selector(setProfile), name: NSNotification.Name(rawValue: GLOBAL_SIGNIN_REFRESH), object: nil)
    }
    
    @objc func setProfile(){
         self.usernameLabel.isHidden = false
         self.usernameLabel.text = AWSMobileClient.default().username
         self.mainButton.setTitle("Sign Out", for: UIControl.State.normal)
    }
    @objc func clearProfile(){
         self.mainButton.setTitle("Sign In", for: UIControl.State.normal)
         self.usernameLabel.isHidden = true
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        switch userGlobalState {
        case .userSignedIn:
            setProfile()
            break
        default:
            clearProfile()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: GLOBAL_NEED_SIGN_UP), object: nil)
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
            clearProfile()
            break
        default:
            userSignIn(navController: self.navigationController!)
            setProfile()
            break
        }

    }
}
