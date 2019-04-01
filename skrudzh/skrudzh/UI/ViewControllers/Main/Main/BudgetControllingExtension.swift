//
//  BudgetControllingExtension.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

extension MainViewController {
    
    func updateBudgetUI() {
        UIView.transition(with: view,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
                            
                            self.budgetView.balanceLabel.text = self.viewModel.balance
                            self.budgetView.monthlySpentLabel.text = self.viewModel.monthlySpent
                            self.budgetView.monthlyPlannedLabel.text = self.viewModel.monthlyPlanned
        })
    }
}
