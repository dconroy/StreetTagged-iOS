//
//  ReviewArtWork.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 9/20/19.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

public class ReviewArtWork: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    var artPiece: Art?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = UIColor.gray
        self.imageView.isHidden = true
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @IBAction func getArt(_ sender: UIButton, forEvent event: UIEvent){
        print("getArt")
        Alamofire.request("https://api-dev.streettagged.com/images/review", method: .get).responseJSON { response in
            
            do {
                let decoder = JSONDecoder()
                let data = try decoder.decode(ArtWorkReview.self, from: response.data!)
                
                if (data.item.count == 1) {
                    let art:Art = data.item[0]
                    self.imageView.loadImage(art.picture)
                    self.artPiece = art
                    self.imageView.isHidden = false
                } else {
                    print("No Art To Review")
                }
            } catch let error {
                print(error)
            }
        }
    }
    
    @IBAction func good(_ sender: UIButton, forEvent event: UIEvent){
        print("good")
        let art: Art = self.artPiece!
        print(art)
        
        let parameters: [String:Any] = [
            "itemId": art.artId,
            "isValid": true
        ]
        
        print(parameters)
        
        Alamofire.request("https://api-dev.streettagged.com/images/review", method: .put, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            print(response.response)
            self.imageView.isHidden = true
            
        }
    }
    
    @IBAction func bad(_ sender: UIButton, forEvent event: UIEvent){
        print("bad")
        let art: Art = self.artPiece!
        print(art)
        
        let parameters: [String:Any] = [
                   "itemId": art.artId,
                   "isValid": false
               ]
               
               print(parameters)
               
               Alamofire.request("https://api-dev.streettagged.com/images/review", method: .put, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                   
                   print(response.response)
                   self.imageView.isHidden = true
                   
               }
    }
    
    @IBAction func dissmiss(_ sender: UIButton, forEvent event: UIEvent){
        self.dismiss(animated: true, completion: nil)
    }
    
}
