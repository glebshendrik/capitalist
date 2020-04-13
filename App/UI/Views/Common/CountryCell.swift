//
//  CountryCollectionViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10.04.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

class CountryCell : UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    var viewModel: CountryViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        nameLabel.text = viewModel?.name
    }
}
