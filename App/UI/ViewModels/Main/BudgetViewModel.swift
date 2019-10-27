//
//  BudgetViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 11/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class BudgetViewModel {
    public private(set) var budget: Budget
    
    var incomesAmountRounded: String {
        return budget.incomesAtPeriodCents.moneyCurrencyString(with: budget.currency, shouldRound: true) ?? ""
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
        
    init(budget: Budget) {
        self.budget = budget
    }
}
