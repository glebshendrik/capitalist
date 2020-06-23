//
//  AddingItemTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 04.05.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

class AddingItemTableViewCell : UITableViewCell {
    @IBOutlet weak var iconView: IconView!
    @IBOutlet weak var addingTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iconView.backgroundViewColor = .clear
        iconView.defaultIconName = "plus-icon"
    }
}
