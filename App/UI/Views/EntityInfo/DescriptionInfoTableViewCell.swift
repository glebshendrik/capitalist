//
//  DescriptionInfoTableViewCell.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 13.10.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

class DescriptionInfoTableViewCell : EntityInfoTableViewCell {
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var descriptionField: DescriptionInfoField? {
        return field as? DescriptionInfoField
    }
    
    override func updateUI() {
        descriptionLabel.text = descriptionField?.description
    }
}
