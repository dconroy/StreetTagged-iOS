//
//  NearByController.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 9/13/19.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation
import Mapbox

public class NearByController: UIViewController {
    
    var mapView = MGLMapView()
    var timer = Timer()
    let locationManager = CLLocationManager()
    var currentAnnotation:[MGLPointAnnotation] = [];
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "mapbox://styles/mapbox/light-v10")
        mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 40.74699, longitude: -73.98742), zoomLevel: 1, animated: false)
        
        for post in posts {
            let pin = MGLPointAnnotation()
            pin.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(post.coordinates[1]), longitude: CLLocationDegrees(post.coordinates[0]))
            self.currentAnnotation.append(pin)
            self.mapView.addAnnotation(pin)
        }
        
        mapView.showsUserLocation = true;
        
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
        view.addSubview(mapView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postUpdates), name: NSNotification.Name(rawValue: GLOBAL_POSTS_REFRESHED), object: nil)
    }
    
    @objc func postUpdates() {
        for annotation in currentAnnotation {
            self.mapView.removeAnnotation(annotation)
        }
        currentAnnotation.removeAll()
        for post in posts {
            let pin = MGLPointAnnotation()
            pin.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(post.coordinates[1]), longitude: CLLocationDegrees(post.coordinates[0]))
            self.currentAnnotation.append(pin)
            self.mapView.addAnnotation(pin)
        }
    }
    
    @objc func timerAction() {
        if (hasGlobalGPS) {
            let locValue: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: globalLatitude!, longitude: globalLongitude!)
            mapView.setCenter(locValue, animated: true)
            mapView.setZoomLevel(15.0, animated: true)
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    deinit {
        timer.invalidate()
    }
}
