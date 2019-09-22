//
//  ViewController.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 9/12/19.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import UIKit
import AWSMobileClient
import Alamofire

struct Art: Decodable {
    let artId: String
    let username: String
    let tags: [String]
    let picture: String
    let isFavorited: Bool?
    let location: Location
    let createdAt: String
}

struct Location: Decodable {
    let type: String
    let coordinates: [Float]
}

struct ArtWorks: Decodable {
    let artWorks: [Art]
}

struct ArtWorkReview: Decodable {
    let item: [Art]
}

struct Headline {
    
    var id : Int
    var title : String
    var text : String
    var image : String
    
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initializeAWSMobileClient()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBOutlet var tableView: UITableView!
    
    let textCellIdentifier = "TextCell"
    
    var items: [Art] = []
    
    let imageCache = NSCache<NSString, UIImage>()

    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        
        let row = indexPath.row
        cell.textLabel?.text = items[row].picture
        
        Alamofire.request(items[row].picture).response { response in
            if let data = response.data {
                let image = UIImage(data: data)
                cell.imageView!.image = image
            } else {

            }
        }
        
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        print(items[row].artId)
    }
    

    func initializeAWSMobileClient() {
        print("initializeAWSMobileClient")
        AWSMobileClient.default().initialize { (userState, error) in
            if let userState = userState {
            switch(userState) {
                case .signedIn:
                    print(AWSMobileClient.default().identityId ?? "")
                default:
                    AWSMobileClient.default().signOut()
            }
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func showSignIn(_ sender: UIButton, forEvent event: UIEvent){
        AWSMobileClient.default().showSignIn(navigationController: self.navigationController!,{ (userState, error) in
            
        })
    }
    
    @IBAction func reviewArt(_ sender: UIButton, forEvent event: UIEvent){
        print("Review Art")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReviewView") as! ReviewArtWork
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func signOut(_ sender: UIButton, forEvent event: UIEvent){
        //AWSMobileClient.default().signOut()
        self.present(TabbarLayOut.tabbar(delegate: self), animated: true, completion: nil)
    }
    
    @IBAction func getUser(_ sender: UIButton, forEvent event: UIEvent){
        AWSMobileClient.default().getTokens { (tokens, error) in
            if let error = error {
                print("Error getting token \(error.localizedDescription)")
            } else if let tokens = tokens {
                print(tokens.accessToken!.tokenString!)
            }
        }
    }
    
    @IBAction func getArtWork(_ sender: UIButton, forEvent event: UIEvent){
        print("getArtWork")
        AWSMobileClient.default().getTokens { (tokens, error) in
            if let error = error {
                print("Error getting token \(error.localizedDescription)")
            } else if let tokens = tokens {
                print(tokens.accessToken!.tokenString!)
                
                let parameters = [
                    "token": tokens.accessToken!.tokenString!
                ]
                
                /*let headers = [
                    "Content-Type": "application/json"
                ]*/
                
                print(parameters)
                
                Alamofire.request("https://api-dev.streettagged.com/search/art", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                    
                    do {
                        let decoder = JSONDecoder()
                        let artWorks = try decoder.decode(ArtWorks.self, from: response.data!)
                        print(artWorks)
                        for art in artWorks.artWorks {
                            print("========================================================")
                            print(art.artId)
                            print(art.username)
                            print(art.isFavorited)
                            print(art.tags)
                            print(art.location)
                            print(art.picture)
                        }
                        self.items = artWorks.artWorks
                        self.tableView.reloadData()
                    } catch let error {
                        print(error.localizedDescription)
                    }
                    
                }
                
            }
        }
        
    }

}

