//
//  ViewController.swift
//  CovidMap
//
//  Created by Michelle Lau on 2020/05/29.
//  Copyright © 2020 Michelle Lau. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class ViewController: UIViewController {
    
    var prefectureArray = [Prefecture]()
    var prefecturePinArray = [PrefecturePin]()
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var lat: CLLocationDegrees?
    var lng: CLLocationDegrees?
    var updatingLocation = false
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        makeAPICall()
        makePrefecturePins()
    }
    
    @IBAction func getCurrentLocation(_ sender: UIButton) {
        let authStatus = CLLocationManager.authorizationStatus()
            if authStatus == .notDetermined {
              locationManager.requestWhenInUseAuthorization()
              return
            }
            if authStatus == .denied || authStatus == .restricted {
              print("denied")
              return
            }
            if updatingLocation {
              stopLocationManager()
            } else {
              location = nil
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
                    let newPrefecture = PrefecturePin(name: self.prefectureArray[i].name, latitude: self.prefectureArray[i].lat, longitude: self.prefectureArray[i].lng)
                    print("name is \(newPrefecture.name) lat is \(newPrefecture.location.coordinate.latitude) lng is \(newPrefecture.location.coordinate.longitude) \n")
                    self.prefecturePinArray.append(newPrefecture)
                    print(self.prefecturePinArray.count)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func makePrefecturePins() {
        for i in 0..<prefectureArray.count {
            let newPrefecture = PrefecturePin(name: prefectureArray[i].name, latitude: prefectureArray[i].lat, longitude: prefectureArray[i].lng)
            print("name is \(newPrefecture.name) lat is \(newPrefecture.location.coordinate.latitude) lng is \(newPrefecture.location.coordinate.longitude) \n")
            prefecturePinArray.append(newPrefecture)
            print(prefecturePinArray.count)
        }
    }

    //MARK: - Start and Stop Location Manager
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
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
        print("---------------Time out")
        if location == nil {
            stopLocationManager()
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!

        if lastLocation.horizontalAccuracy < 0 {
            return
        }
        if location == nil || location!.horizontalAccuracy > lastLocation.horizontalAccuracy {
            location = lastLocation
            stopLocationManager()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error.localizedDescription)")
        
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        stopLocationManager()
    }
}
