//
//  ActiveExpenseCategoryTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class ActiveExpenseCategoryTableViewCell : ExpenseCategoryTableViewCell {
    
    override func updateUI() {
        super.updateUI()
        guard let viewModel = viewModel else { return }
        spentLabel.text = viewModel.includedInBalanceExpensesAmount
    }
}
