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
    let lat: String
    let lng: String
    let cases: String
    let deaths: String
    
    init(json: JSON) {
        self.name = json["name_en"].stringValue
        self.lat = json["lat"].stringValue
        self.lng = json["lng"].stringValue
        self.cases = json["cases"].stringValue
        self.deaths = json["deaths"].stringValue
    }
}
