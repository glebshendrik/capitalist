//
//  BasicInfoTableViewCell.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 13.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class BasicInfoTableViewCell : EntityInfoTableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    var basicField: BasicInfoField? {
        return field as? BasicInfoField
    }
    
    override func updateUI() {
        titleLabel.text = basicField?.title
        valueLabel.text = basicField?.value
    }
}
