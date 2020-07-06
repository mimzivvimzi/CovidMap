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

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var place: PrefecturePin?
    var places: [PrefecturePin] = []
    
    var prefectureArray = [Prefecture]()
    var prefecturePinArray = [PrefecturePin]()
    
    var testLocation: CLLocationCoordinate2D?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeAPICall()
        mapView.delegate = self
        self.title = "COVID-19 Map by Prefecture"
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
