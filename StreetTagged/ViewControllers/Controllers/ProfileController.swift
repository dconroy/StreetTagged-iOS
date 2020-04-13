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
import Eureka

let SIGN_IN_LABEL = "Sign In"
let SIGN_OUT_LABEL = "Sign Out"
let TAGS_LABEL = "Tags"

public class ProfileController: FormViewController {
    
    var awsAuthRow: ButtonRow?
    var tagsRow: ButtonRow?
    var tagsRendered: Bool = false
    
    deinit {

    }
    
    public override func viewWillAppear(_ animated: Bool) {
        switch userGlobalState {
            case .userSignedIn:
                awsAuthRow?.title = SIGN_OUT_LABEL
                break
            default:
                awsAuthRow?.title = SIGN_IN_LABEL
                break
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tagsRow = ButtonRow(){ row in
            row.title = TAGS_LABEL
            row.onCellSelection { cell, row in
                switch userGlobalState {
                    case .userSignedIn:
                        let controller = TagsViewController()
                        let navigationController = UINavigationController.init(rootViewController: controller)
                        navigationController.modalPresentationStyle = .fullScreen
                        self.present(navigationController, animated: true, completion: nil)
                        break
                    default:
                        break
                }
            }
        }
        
        self.awsAuthRow = ButtonRow(){ row in
            switch userGlobalState {
                case .userSignedIn:
                    row.title = SIGN_OUT_LABEL
                    break
                default:
                    row.title = SIGN_IN_LABEL
            }
            row.onCellSelection { cell, row in
                switch userGlobalState {
                    case .userSignedIn:
                        userSignOut()
                        row.title = SIGN_IN_LABEL
                        self.tagsRow?.disabled = true
                        break
                    default:
                        userSignIn(navController: self.navigationController!)
                        break
                }
                row.reload()
            }
        }
        
        form
        +++ Section(header: "My Account", footer: "For our privacy policy please visit: https://streettagged.com/privacypolicy.html")
            <<< self.awsAuthRow!
        
        +++ Section(header: "Feed Settings", footer: "")
            <<< self.self.tagsRow!
    }
}
