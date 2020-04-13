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

public class ProfileController: FormViewController {
    
    var awsAuthRow: ButtonRow?
    
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
                        break
                    default:
                        userSignIn(navController: self.navigationController!)
                        break
                }
                row.reload()
            }
        }
        
        form
        +++ Section(header: "Authentication", footer: "For our privacy policy please visit: https://streettagged.com/privacypolicy.html")
            <<< self.awsAuthRow!
    }
}

/*
public class ProfileController: UIViewController {
    
    @IBOutlet var mainButton: UIButton!
    @IBOutlet var usernameLabel: UILabel!
    
    weak var tableView: UITableView!
    
    var actions: [String] = []
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 244.0 / 255.0, green: 245.0 / 255.0, blue: 245.0 / 255.0, alpha: 1.0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: GLOBAL_SIGNIN_REFRESH), object: nil)
        
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
            self.view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: tableView.topAnchor),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
            self.view.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
        ])
        self.tableView = tableView
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    
    
    public override func viewWillAppear(_ animated: Bool) {
        refresh()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @IBAction func reviewArt(_ sender: UIButton, forEvent event: UIEvent){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReviewView") as! ReviewArtWork
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func refresh() {
        actions.removeAll()
        switch userGlobalState {
        case .userSignedIn:
            actions.append("Sign Out")
            break
        default:
            actions.append("Sign In")
        }
        self.tableView.reloadData()
    }
    
    func action() {
        switch userGlobalState {
        case .userSignedIn:
            userSignOut()
            break
        default:
            userSignIn(navController: self.navigationController!)
            break
        }
        
    }
}

extension ProfileController: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.actions.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        let item = self.actions[indexPath.item]
        cell.textLabel?.text = item
        return cell
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch userGlobalState {
        case .userSignedIn:
            return AWSMobileClient.default().username
        default:
            return "My Accounts"
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        action()
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "For our privacy policy please visit: https://streettagged.com/privacypolicy.html"
    }
    
}
*/
