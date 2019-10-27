//
//  BudgetControllingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension MainViewController : TitleViewDelegate {
    func didTapTitle() {
        showBalance()
    }
    
    func updateBudgetUI() {
        UIView.transition(with: view,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
                            
            self.incomeSourcesAmountLabel.text = self.viewModel.incomesAmountRounded
            self.expenseSourcesAmountLabel.text = self.viewModel.expenseSourcesAmountRounded
            self.basketTotalTitleLabel.text = self.viewModel.basketTotalTitle
            self.basketTotalLabel.text = self.viewModel.basketTotal
        })
    }
    
    func updateTotalUI() {
        UIView.transition(with: view,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
                            
            self.basketTotalTitleLabel.text = self.viewModel.basketTotalTitle
            self.basketTotalLabel.text = self.viewModel.basketTotal
            self.basketTotalTitleLabel.alpha = self.isEditing ? 0.0 : 1.0
            self.basketTotalLabel.alpha = self.isEditing ? 0.0 : 1.0
        })
    }
}
