//
//  ExpenseCategoryViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 17/01/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation

class ExpenseCategoryViewModel {
    
    public private(set) var expenseCategory: ExpenseCategory
    
    var id: Int {
        return expenseCategory.id
    }
    
    var name: String {
        return expenseCategory.name
    }
    
    var monthlyPlanned: String? {
        return expenseCategory.monthlyPlannedCents.moneyStringWithCurrency(symbol: "₽")
    }
    
    var monthlySpent: String? {
        return expenseCategory.monthlySpentCents.moneyStringWithCurrency(symbol: "₽")
    }
    
    var areMonthlyExpensesPlanned: Bool {
        return expenseCategory.monthlyPlannedCents > 0
    }
    
    var monthlySpentProgress: Double {
        guard areMonthlyExpensesPlanned else { return 0 }
        let progress = Double(expenseCategory.monthlySpentCents) / Double(expenseCategory.monthlyPlannedCents)
        return progress > 1.0 ? 1.0 : progress
    }
    
    var isMonthlyPlanCompleted: Bool {
        return monthlySpentProgress == 1.0
    }
    
    var iconURL: URL? {
        return expenseCategory.iconURL
    }
    
    init(expenseCategory: ExpenseCategory) {
        self.expenseCategory = expenseCategory
    }
}