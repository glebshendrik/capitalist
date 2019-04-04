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
    
    var currency: Currency {
        return expenseCategory.currency
    }
    
    var basketType: BasketType {
        return expenseCategory.basketType
    }
    
    var monthlyPlanned: String? {
        return expenseCategory.monthlyPlannedCents?.moneyCurrencyString(with: currency, shouldRound: true)
    }
    
    var monthlySpentRounded: String? {
        return monthlySpent(shouldRound: true)
    }
    
    var monthlySpent: String? {
        return monthlySpent(shouldRound: false)
    }
    
    var areMonthlyExpensesPlanned: Bool {
        guard let monthlyPlannedCents = expenseCategory.monthlyPlannedCents else { return false }
        return monthlyPlannedCents > 0
    }
    
    var monthlySpentProgress: Double {
        guard areMonthlyExpensesPlanned, let monthlyPlannedCents = expenseCategory.monthlyPlannedCents else { return 0 }
        let progress = Double(expenseCategory.monthlySpentCents) / Double(monthlyPlannedCents)
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
    
    private func monthlySpent(shouldRound: Bool) -> String? {
        return expenseCategory.monthlySpentCents.moneyCurrencyString(with: currency, shouldRound: shouldRound)
    }
}

extension ExpenseCategoryViewModel : TransactionCompletable {
    var amountRounded: String {
        return monthlySpentRounded ?? ""
    }
    
    var amount: String {
        return monthlySpent ?? ""
    }
    
    func canComplete(startable: TransactionStartable) -> Bool {
        return startable is ExpenseSourceViewModel
    }
}
