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
import SwiftyJSON
import Alamofire

class MapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var place: PrefecturePin?
    var places: [PrefecturePin] = []
    
    var prefectureArray = [Prefecture]()
    var prefecturePinArray = [PrefecturePin]()
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var region = MKCoordinateRegion()
    var lat: CLLocationDegrees?
    var lng: CLLocationDegrees?
    var updatingLocation = false
    var lastLocationError: Error?
    var timer: Timer?
    
    var testLocation: CLLocationCoordinate2D?
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeAPICall()
        mapView.delegate = self
        self.title = "COVID-19 Map by Prefecture"
    }
    
    @IBAction func getCurrentLocation(_ sender: UIButton) {
        locationManager.startUpdatingLocation()

        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }

        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            print("get current location pressed")
            startLocationManager()
        }
    }

    func makeAPICall() {
        AF.request("https://covid19-japan-web-api.now.sh/api/v1/prefectures").validate().responseJSON { (response) in
            switch response.result {
            case .success(_):
                guard let value = response.value else { return }
                let json = JSON(value)
                for i in 0..<json.count {
                    let newPrefecture = Prefecture(json: json[i])
                    self.prefectureArray.append(newPrefecture)
                    print(self.prefectureArray.count)
                }
                for i in 0..<self.prefectureArray.count {
                    let newPrefecture = PrefecturePin(name: self.prefectureArray[i].name, latitude: self.prefectureArray[i].lat, longitude: self.prefectureArray[i].lng, cases: self.prefectureArray[i].cases, deaths: self.prefectureArray[i].deaths)
                    print("name is \(newPrefecture.name) lat is \(newPrefecture.location.coordinate.latitude) lng is \(newPrefecture.location.coordinate.longitude) \n")
                    self.prefecturePinArray.append(newPrefecture)
                    print(self.prefecturePinArray.count)
                }
                self.testLocation = self.prefecturePinArray[12].location.coordinate
                let regionRadius: CLLocationDistance = 200000.0
                let region = MKCoordinateRegion(center: self.testLocation!, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
                self.mapView.setRegion(region, animated: true)
                self.mapView.addAnnotations(self.prefecturePinArray)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    //MARK: - CLLocationManagerDelegate
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("didFailWithError \(error.localizedDescription)")
            
            if (error as NSError).code == CLError.locationUnknown.rawValue {
                return
            }
            lastLocationError = error
            stopLocationManager()
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let newLocation = locations.last else { return }
           
            let span = MKCoordinateSpan(latitudeDelta: 0.6, longitudeDelta: 0.6)
            let myLocation = newLocation.coordinate
            let region = MKCoordinateRegion(center: myLocation, span: span)

            map.setRegion(region, animated: true)
            self.map.showsUserLocation = true
            manager.stopUpdatingLocation()
            
            print("didUpdateLocations \(newLocation)")
            
            // IF IT TAKES MORE THAN 5 SECONDS
            if newLocation.timestamp.timeIntervalSinceNow < -5 {
                return
            }
            // INVALID HORIZONTAL READING
            if newLocation.horizontalAccuracy < 0 {
                return
            }
            
            // NEW PARTS FOR FIXES
            var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
            if let location = location {
                distance = location.distance(from: location)
            }
        }
     
     //MARK: - Start and Stop the Location Manager
     func startLocationManager() {
         if CLLocationManager.locationServicesEnabled() {
             locationManager.delegate = self
             locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
             locationManager.startUpdatingLocation()
             updatingLocation = true
             timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
            
            
            let regionRadius: CLLocationDistance = 200000.0
            let region = MKCoordinateRegion(center: self.testLocation!, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            self.mapView.setRegion(region, animated: true)
            
            
         }
     }
     
     func stopLocationManager() {
         if updatingLocation {
             locationManager.stopUpdatingLocation()
             locationManager.delegate = nil
             updatingLocation = false
             if let timer = timer {
                 timer.invalidate()
             }
         }
     }
     
     @objc func didTimeOut() {
         print("*** Time out")
         if location == nil {
             stopLocationManager()
             lastLocationError = NSError(domain: "ErrorDomain", code: 1, userInfo: nil)
         }
     }
    
    //MARK: - Helper Methods
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Serices Disabled", message: "Please enable location services for this app in Settings", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        print("rendering...")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "PrefecturePin") as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "PrefecturePin")
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
}
