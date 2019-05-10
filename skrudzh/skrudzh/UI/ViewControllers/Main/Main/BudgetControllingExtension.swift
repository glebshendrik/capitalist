//
//  BudgetControllingExtension.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

extension MainViewController : BudgetViewDelegate {
    func didTapBalance() {
        showBalance()
    }
    
    func updateBudgetUI() {
        UIView.transition(with: view,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
                            
                            self.budgetView.balanceLabel.text = self.viewModel.balance
                            self.budgetView.spentLabel.text = self.viewModel.spent
                            self.budgetView.plannedLabel.text = self.viewModel.planned
        })
    }
}
