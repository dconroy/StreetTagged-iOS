//
//  NearByController.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 9/13/19.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation
import Mapbox

public class NearByController: UIViewController, CLLocationManagerDelegate {
    
    var mapView = MGLMapView()
    let locationManager = CLLocationManager()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "mapbox://styles/mapbox/light-v10")
        mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 40.74699, longitude: -73.98742), zoomLevel: 9, animated: false)
        
        for post in posts {
            let pin = MGLPointAnnotation()
            pin.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(post.coordinates[1]), longitude: CLLocationDegrees(post.coordinates[0]))
            mapView.addAnnotation(pin)
        }
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        //mapView.showsUserLocation = true;
        view.addSubview(mapView)
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        mapView.setCenter(locValue, animated: true)
        mapView.setZoomLevel(12.0, animated: true)
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

}
