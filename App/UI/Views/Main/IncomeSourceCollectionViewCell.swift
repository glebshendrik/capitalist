//
//  IncomeSourceCollectionViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit

class IncomeSourceCollectionViewCell : EditableCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var incomeAmountLabel: UILabel!
    
    var viewModel: IncomeSourceViewModel? {
        didSet {
            updateUI()
        }
    }
    
    override var canDelete: Bool {
        guard let viewModel = viewModel else { return super.canDelete }
        return !viewModel.isChild
    }
    
    func updateUI() {
        nameLabel.text = viewModel?.name
        incomeAmountLabel.text = viewModel?.amountRounded
    }
}

