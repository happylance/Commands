//
//  LocationTrackingManager.swift
//  Commands
//
//  Created by Liu Liang on 5/1/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import Foundation
import CoreLocation

class LocationTrackingManager : NSObject {
    lazy var locationManager : CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        return _locationManager
    }()
    
    lazy var locations = [CLLocation]()
}

extension LocationTrackingManager: CLLocationManagerDelegate {
}
