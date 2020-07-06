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

class ViewController: UITableViewController, CLLocationManagerDelegate {
    
    var prefectureArray = [Prefecture]()
    var prefecturePinArray = [PrefecturePin]()
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var lat: CLLocationDegrees?
    var lng: CLLocationDegrees?
    var updatingLocation = false
    var lastLocationError: Error?
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "COVID-19 Data by Prefecture"
        makeAPICall()
    }
    
    @IBAction func getCurrentLocation(_ sender: UIButton) {
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
                print("***********\(self.prefecturePinArray[0].location.coordinate)")
                self.tableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
//    func makePrefecturePins() {
//        for i in 0..<prefectureArray.count {
//            let newPrefecture = PrefecturePin(name: prefectureArray[i].name, latitude: prefectureArray[i].lat, longitude: prefectureArray[i].lng)
//            print("name is \(newPrefecture.name) lat is \(newPrefecture.location.coordinate.latitude) lng is \(newPrefecture.location.coordinate.longitude) \n")
//            prefecturePinArray.append(newPrefecture)
//            print(prefecturePinArray.count)
//        }
//    }

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
           let newLocation = locations.last!
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
               distance = newLocation.distance(from: location)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MapSegue" {
            guard let destination = segue.destination as? MapViewController else { return }
            destination.place = prefecturePinArray[13]
            destination.places = prefecturePinArray
        }
    }


//extension ViewController: CLLocationManagerDelegate {
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let newLocation = locations.last!
//            print("didUpdateLocations \(newLocation)")
//
//            // IF IT TAKES MORE THAN 5 SECONDS
//            if newLocation.timestamp.timeIntervalSinceNow < -5 {
//                return
//            }
//            // INVALID HORIZONTAL READING
//            if newLocation.horizontalAccuracy < 0 {
//                return
//            }
//
//            // NEW PARTS FOR FIXES
//            var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
//            if let currentLocation = currentLocation {
//                distance = newLocation.distance(from: currentLocation)
//            } else if distance > 1 {
//            let timeInterval = newLocation.timestamp.timeIntervalSince(currentLocation!.timestamp)
//            if timeInterval > 10 {
//                print("*** Force done!")
//                stopLocationManager()
//            }
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("didFailWithError \(error.localizedDescription)")
//
//        if (error as NSError).code == CLError.locationUnknown.rawValue {
//            return
//        }
//        stopLocationManager()
//    }
//
    //MARK: - Helper Methods
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Serices Disabled", message: "Please enable location services for this app in Settings", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prefectureArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        cell.prefectureLabel.text = prefectureArray[indexPath.row].name
        cell.casesLabel.text = "Cases: \(prefectureArray[indexPath.row].cases)"
        cell.deathsLabel.text = "Deaths: \(prefectureArray[indexPath.row].deaths)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(120)
    }
}
