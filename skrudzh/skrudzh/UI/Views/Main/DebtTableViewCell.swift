//
//  DebtTableViewCell.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 07/05/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

class DebtTableViewCell : UITableViewCell {
    @IBOutlet weak var whomLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var gotAtLabel: UILabel!
    @IBOutlet weak var borrowedTillLabel: UILabel!
    
    var viewModel: FundsMoveViewModel? = nil {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        whomLabel.text = viewModel?.whomLabelTitle
        amountLabel.text = viewModel?.debtAmount
        gotAtLabel.text = viewModel?.gotAtFormatted
        borrowedTillLabel.text = viewModel?.borrowedTillLabelTitle
    }
}
