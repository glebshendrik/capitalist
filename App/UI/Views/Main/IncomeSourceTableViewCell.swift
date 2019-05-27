//
//  IncomeSourceTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 14/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class IncomeSourceTableViewCell : UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var incomeAmountLabel: UILabel!
    
    var viewModel: IncomeSourceViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        nameLabel.text = viewModel?.name
        incomeAmountLabel.text = viewModel?.amountRounded
    }
}
