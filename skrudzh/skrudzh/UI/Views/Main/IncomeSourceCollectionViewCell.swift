//
//  IncomeSourceCollectionViewCell.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 13/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit

class IncomeSourceCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var incomeAmountLabel: UILabel!
    
    var viewModel: IncomeSourceViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        nameLabel.text = viewModel?.name
        incomeAmountLabel.text = viewModel?.incomesAmount
    }
}

