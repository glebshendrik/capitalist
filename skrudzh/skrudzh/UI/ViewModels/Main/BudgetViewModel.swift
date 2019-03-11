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
    
    var balance: String {
        return budget.balanceCents.moneyCurrencyString(with: budget.currency) ?? ""
    }
    
    var monthlySpent: String {
        return budget.monthlySpentCents.moneyCurrencyString(with: budget.currency) ?? ""
    }
    
    var monthlyPlanned: String {
        return budget.monthlyPlannedCents.moneyCurrencyString(with: budget.currency) ?? ""
    }
    
    init(budget: Budget) {
        self.budget = budget
    }
}
