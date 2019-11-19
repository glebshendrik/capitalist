//
//  BasicInfoTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class BasicInfoTableViewCell : UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    var field: BasicInfoField? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {        
        titleLabel.text = field?.title
        valueLabel.text = field?.value
    }
}
