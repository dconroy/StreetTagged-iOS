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
        
        mapView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.styleURL = MGLStyle.lightStyleURL
        
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
        
        
        let styleToggle = UISegmentedControl(items: ["Satellite", "Light", "Streets"])
        styleToggle.translatesAutoresizingMaskIntoConstraints = false
        styleToggle.tintColor = UIColor(red: 0.976, green: 0.843, blue: 0.831, alpha: 1)
        styleToggle.backgroundColor = UIColor(red: 0.973, green: 0.329, blue: 0.294, alpha: 1)
        styleToggle.layer.cornerRadius = 4
        styleToggle.clipsToBounds = true
        styleToggle.selectedSegmentIndex = 1
        view.insertSubview(styleToggle, aboveSubview: mapView)
        styleToggle.addTarget(self, action: #selector(changeStyle(sender:)), for: .valueChanged)
        
        // Configure autolayout constraints for the UISegmentedControl to align
        // at the bottom of the map view and above the Mapbox logo and attribution
        NSLayoutConstraint.activate([NSLayoutConstraint(item: styleToggle, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mapView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0.0)])
        NSLayoutConstraint.activate([NSLayoutConstraint(item: styleToggle, attribute: .bottom, relatedBy: .equal, toItem: mapView.logoView, attribute: .top, multiplier: 1, constant: -20)])
        
        
        // Create button to allow user to change the tracking mode.
        setupLocationButton()
        postUpdates()
    }
    
    @objc func changeStyle(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.styleURL = MGLStyle.satelliteStyleURL
        case 1:
            mapView.styleURL = MGLStyle.lightStyleURL
        case 2:
            mapView.styleURL = MGLStyle.streetsStyleURL
        default:
            mapView.styleURL = MGLStyle.lightStyleURL
        }
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
        for post in posts {
            let pin = CLLocationCoordinate2D(latitude: CLLocationDegrees(post.coordinates[1]), longitude: CLLocationDegrees(post.coordinates[0]))
            let imagePin = CustomAnnotation(coordinate: pin,title: post.about, subtitle: post.username, image: post.image)
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
        {
            let customAnnotation = CustomAnnotation(coordinate: annotation.coordinate, title: point.title ?? "no title", subtitle: point.subtitle ?? "no subtitle", image: point.image!)
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
