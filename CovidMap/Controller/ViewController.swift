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
    
    let locationManager = CLLocationManager()
    var location: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        makeAPICall()
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
                    print(self.prefectureArray[i].name)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }


}

