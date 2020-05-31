//
//  PrefecturePin.swift
//  CovidMap
//
//  Created by Michelle Lau on 2020/05/31.
//  Copyright © 2020 Michelle Lau. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class PrefecturePin: NSObject {
    let name: String
    let location: CLLocation
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.location = CLLocation(latitude: latitude, longitude: longitude)
    }
    
}

extension PrefecturePin: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        get {
            return location.coordinate
        }
    }
    
    var title: String? {
        get {
            return name
        }
    }
}
