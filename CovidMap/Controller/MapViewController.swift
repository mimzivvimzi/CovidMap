//
//  MapViewController.swift
//  CovidMap
//
//  Created by Michelle Lau on 2020/05/31.
//  Copyright © 2020 Michelle Lau. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tokyo = CLLocation(latitude: 35.702313700000005, longitude: 139.5803228)
        let regionRadius: CLLocationDistance = 1000.0
        let region = MKCoordinateRegion(center: tokyo.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(region, animated: true)
        mapView.delegate = self
    }

}

extension MapViewController: MKMapViewDelegate {
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        print("rendering...")
    }
}
