//
//  BudgetViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 11/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class BudgetViewModel {
    public private(set) var budget: Budget
    
    var incomesAmountRounded: String {
        return budget.incomesAtPeriodCents.moneyCurrencyString(with: budget.currency, shouldRound: true) ?? ""
    }
    
    var incomesAmountPlannedRounded: String {
        guard budget.incomesPlannedAtPeriodCents > 0 else { return "" }
        return budget.incomesPlannedAtPeriodCents.moneyCurrencyString(with: budget.currency, shouldRound: true) ?? ""
    }
    
    var expenseSourcesAmountRounded: String {
        return budget.expenseSourcesAmountCents.moneyCurrencyString(with: budget.currency, shouldRound: true) ?? ""
    }
    
    var safeActivesAmountRounded: String {
        return budget.safeActivesAmountCents.moneyCurrencyString(with: budget.currency, shouldRound: true) ?? ""
    }
        
    var riskActivesAmountRounded: String {
        return budget.riskActivesAmountCents.moneyCurrencyString(with: budget.currency, shouldRound: true) ?? ""
    }
    
    var activesAmountRounded: String {
        return budget.activesAmountCents.moneyCurrencyString(with: budget.currency, shouldRound: true) ?? ""
    }
    
    var expensesAmountRounded: String {
        return budget.expensesAtPeriodCents.moneyCurrencyString(with: budget.currency, shouldRound: true) ?? ""
    }
    
    var expensesAmountPlannedRounded: String {
        guard budget.expensesPlannedAtPeriodCents > 0 else { return "" }
        return budget.expensesPlannedAtPeriodCents.moneyCurrencyString(with: budget.currency, shouldRound: true) ?? ""
    }
      
    var incomesProgress: CGFloat {
        guard budget.incomesPlannedAtPeriodCents > 0 else { return 0.0 }
        let progress = CGFloat(budget.incomesAtPeriodCents) / CGFloat(budget.incomesPlannedAtPeriodCents)
        return progress > 1.0 ? 1.0 : progress
    }
    
    var expensesProgress: CGFloat {
        guard budget.expensesPlannedAtPeriodCents > 0 else { return 0.0 }
        let progress = CGFloat(budget.expensesAtPeriodCents) / CGFloat(budget.expensesPlannedAtPeriodCents)
        return progress > 1.0 ? 1.0 : progress
    }
    
    init(budget: Budget) {
        self.budget = budget
    }
}
