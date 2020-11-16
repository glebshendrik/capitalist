//
//  IncomeSourceTableViewCell.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 14/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SwipeCellKit

class IncomeSourceTableViewCell : SwipeTableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var incomeAmountLabel: UILabel!
    @IBOutlet weak var iconView: IconView!
    
    var viewModel: IncomeSourceViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        guard let viewModel = viewModel else { return }
        
        nameLabel.text = viewModel.name
        incomeAmountLabel.text = viewModel.amountRounded
        
        iconView.vectorIconMode = .fullsize
        iconView.iconURL = viewModel.iconURL
        iconView.defaultIconName = viewModel.defaultIconName
        iconView.backgroundViewColor = .clear
        iconView.iconTintColor = UIColor.by(.white100)
    }
}
