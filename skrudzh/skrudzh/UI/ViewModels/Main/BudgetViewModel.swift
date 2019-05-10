//
//  BudgetViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 11/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation

class BudgetViewModel {
    public private(set) var budget: Budget
    
    var balanceRounded: String {
        return budget.balanceCents.moneyCurrencyString(with: budget.currency, shouldRound: true) ?? ""
    }
    
    var balance: String {
        return budget.balanceCents.moneyCurrencyString(with: budget.currency, shouldRound: false) ?? ""
    }
    
    var expenseSourcesBalance: String {
        return budget.expenseSourcesBalanceCents.moneyCurrencyString(with: budget.currency, shouldRound: false) ?? ""
    }
    
    var includedInBalanceExpenses: String {
        return budget.includedInBalanceExpensesCents.moneyCurrencyString(with: budget.currency, shouldRound: false) ?? ""
    }
    
    var spent: String {
        return budget.spentCentsAtPeriod.moneyCurrencyString(with: budget.currency, shouldRound: true) ?? ""
    }
    
    var planned: String {
        return budget.plannedCentsAtPeriod.moneyCurrencyString(with: budget.currency, shouldRound: true) ?? ""
    }
    
    init(budget: Budget) {
        self.budget = budget
    }
}
