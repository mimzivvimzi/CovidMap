//
//  TableViewCell.swift
//  CovidMap
//
//  Created by Michelle Lau on 2020/07/05.
//  Copyright © 2020 Michelle Lau. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var prefectureLabel: UILabel!
    @IBOutlet weak var casesLabel: UILabel!
    @IBOutlet weak var deathsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
