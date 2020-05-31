//
//  Prefecture.swift
//  CovidMap
//
//  Created by Michelle Lau on 2020/05/29.
//  Copyright © 2020 Michelle Lau. All rights reserved.
//

import Foundation
import SwiftyJSON

class Prefecture {
    let name: String
    let lat: Double
    let lng: Double
    let cases: String
    let deaths: String
    
    init(json: JSON) {
        self.name = json["name_en"].stringValue
        self.lat = json["lat"].doubleValue
        self.lng = json["lng"].doubleValue
        self.cases = json["cases"].stringValue
        self.deaths = json["deaths"].stringValue
    }
}
