//
//  NearByController.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 9/13/19.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation
import Mapbox

public class NearByController: UIViewController, MGLMapViewDelegate {
    
    var mapView = MGLMapView()
    
    var userLocationButton: UserLocationButton?
    let locationManager = CLLocationManager()
    var currentAnnotation:[MGLPointAnnotation] = [];
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "mapbox://styles/mapbox/light-v10")
        mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if (hasGlobalGPS) {
            mapView.setCenter(CLLocationCoordinate2D(latitude: globalLatitude!, longitude: globalLongitude!), zoomLevel: 15, animated: false)
        } else {
            mapView.setCenter(CLLocationCoordinate2D(latitude: 40.74699, longitude: -73.98742), zoomLevel: 1, animated: false)
        }
        
        // The user location annotation takes its color from the map view's tint color.
        mapView.tintColor = .blue
        mapView.attributionButton.tintColor = .lightGray
        mapView.showsUserHeadingIndicator = true
        mapView.showsUserLocation = true;
        
        
        
        view.addSubview(mapView)
        // Set the delegate property of our map view to `self` after instantiating it.
        mapView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(postUpdates), name: NSNotification.Name(rawValue: GLOBAL_POSTS_REFRESHED), object: nil)
        
        // Create button to allow user to change the tracking mode.
        setupLocationButton()
        postUpdates()
    }
    // Update the user tracking mode when the user toggles through the
    // user tracking mode button.
    @IBAction func locationButtonTapped(sender: UserLocationButton) {
        if (hasGlobalGPS) {
            mapView.setCenter(CLLocationCoordinate2D(latitude: globalLatitude!, longitude: globalLongitude!), zoomLevel: 15, animated: true)
        }
    }
    
    // Button creation and autolayout setup
    func setupLocationButton() {
        let userLocationButton = UserLocationButton(buttonSize: 40)
        userLocationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        
        // Setup constraints such that the button is placed within
        // the upper left corner of the view.
        userLocationButton.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(item: userLocationButton, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: userLocationButton, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: userLocationButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: userLocationButton.frame.size.height),
            NSLayoutConstraint(item: userLocationButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: userLocationButton.frame.size.width)
        ]
        
        
        view.addSubview(userLocationButton)
        view.addConstraints(constraints)
        
        self.userLocationButton = userLocationButton
    }
    
    
    @objc func postUpdates() {
        // Declare the marker `hello` and set its coordinates, title, and subtitle.
        
        
        for post in posts {
            let imageUrlString = post.image
            let pin = CLLocationCoordinate2D(latitude: CLLocationDegrees(post.coordinates[1]), longitude: CLLocationDegrees(post.coordinates[0]))
            let imageUrl = URL(string: imageUrlString)!

            let imageData = try! Data(contentsOf: imageUrl)

            let image = UIImage(data: imageData)
            
            let imagePin = CustomAnnotation(coordinate: pin,title: post.about , subtitle: post.username, image: image!)     // Add marker `hello` to the map.
            mapView.addAnnotation(imagePin)
        }
        
    }
    
    // Use the default marker. See also: our view annotation or custom marker examples.
    public  func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        return nil
    }
    
    // Allow callout view to appear when an annotation is tapped.
    public   func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    
    public   func mapView(_ mapView: MGLMapView, calloutViewFor annotation: MGLAnnotation) -> MGLCalloutView? {
        
        if let point = annotation as? CustomAnnotation
        { let image = point.image
            let customAnnotation = CustomAnnotation(coordinate: annotation.coordinate, title: point.title ?? "no title", subtitle: point.subtitle ?? "no subtitle", image: image)
            return CustomCalloutView(annotation: customAnnotation)
        }
        return nil
    }
    
    deinit {
        
    }
}

class UserLocationButton: UIButton {
    private var arrow: CAShapeLayer?
    private let buttonSize: CGFloat
    
    // Initializer to create the user tracking mode button
    init(buttonSize: CGFloat) {
        self.buttonSize = buttonSize
        super.init(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        self.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        self.layer.cornerRadius = 4
        
        let arrow = CAShapeLayer()
        arrow.path = arrowPath()
        arrow.lineWidth = 2
        arrow.lineJoin = CAShapeLayerLineJoin.round
        arrow.bounds = CGRect(x: 0, y: 0, width: buttonSize / 2, height: buttonSize / 2)
        arrow.position = CGPoint(x: buttonSize / 2, y: buttonSize / 2)
        arrow.shouldRasterize = true
        arrow.rasterizationScale = UIScreen.main.scale
        arrow.drawsAsynchronously = true
        
        self.arrow = arrow
        
        // Update arrow for initial tracking mode
        updateArrow(fillColor: UIColor.black, strokeColor: UIColor.black, rotation: CGFloat(0.66))
        layer.addSublayer(self.arrow!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Create a new bezier path to represent the tracking mode arrow,
    // making sure the arrow does not get drawn outside of the
    // frame size of the UIButton.
    private func arrowPath() -> CGPath {
        let bezierPath = UIBezierPath()
        let max: CGFloat = buttonSize / 2
        bezierPath.move(to: CGPoint(x: max * 0.5, y: 0))
        bezierPath.addLine(to: CGPoint(x: max * 0.1, y: max))
        bezierPath.addLine(to: CGPoint(x: max * 0.5, y: max * 0.65))
        bezierPath.addLine(to: CGPoint(x: max * 0.9, y: max))
        bezierPath.addLine(to: CGPoint(x: max * 0.5, y: 0))
        bezierPath.close()
        
        return bezierPath.cgPath
    }
    
    func updateArrow(fillColor: UIColor, strokeColor: UIColor, rotation: CGFloat) {
        guard let arrow = arrow else { return }
        arrow.fillColor = fillColor.cgColor
        arrow.strokeColor = strokeColor.cgColor
        arrow.setAffineTransform(CGAffineTransform.identity.rotated(by: rotation))
        
        // Re-center the arrow within the button if rotated
        if rotation > 0 {
            arrow.position = CGPoint(x: buttonSize / 2 + 2, y: buttonSize / 2 - 2)
        }
        
        layoutIfNeeded()
    }
}
