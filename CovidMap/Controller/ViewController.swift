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

class ViewController: UITableViewController {
    
    var prefectureArray = [Prefecture]()
    var prefecturePinArray = [PrefecturePin]()
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "COVID-19 Data by Prefecture"
        makeAPICall()
    }

    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MapSegue" {
            guard let destination = segue.destination as? MapViewController else { return }
            destination.place = prefecturePinArray[13]
            destination.places = prefecturePinArray
        }
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
