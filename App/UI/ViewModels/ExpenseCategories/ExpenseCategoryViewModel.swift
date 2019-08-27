//
//  ExpenseCategoryViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 17/01/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
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
    
    var planned: String? {
        return expenseCategory.plannedCentsAtPeriod?.moneyCurrencyString(with: currency, shouldRound: true)
    }
    
    var spentRounded: String? {
        return spent(shouldRound: true)
    }
    
    var spent: String? {
        return spent(shouldRound: false)
    }
    
    var includedInBalanceExpensesAmount: String? {
        return expenseCategory.includedInBalanceExpensesCents?.moneyCurrencyString(with: currency, shouldRound: false)
    }
    
    var profit: String? {
        guard hasProfit, let profit = expenseCategory.profitCents?.moneyCurrencyString(with: currency, shouldRound: false) else { return nil }
        var sign = ""
        if isProfitPositive { sign = "+" }
        return "\(sign)\(profit)"
    }
    
    var hasProfit: Bool {
        return expenseCategory.profitCents != nil
    }
    
    var isProfitPositive: Bool {
        guard let profitCents = expenseCategory.profitCents else { return false }
        return profitCents > 0
    }
    
    var isProfitNegative: Bool {
        guard let profitCents = expenseCategory.profitCents else { return false }
        return profitCents < 0
    }
    
    var areExpensesPlanned: Bool {
        guard let plannedCentsAtPeriod = expenseCategory.plannedCentsAtPeriod else { return false }
        return plannedCentsAtPeriod > 0
    }
    
    var spendingProgress: Double {
        guard   areExpensesPlanned,
                let plannedCentsAtPeriod = expenseCategory.plannedCentsAtPeriod else { return 0 }
        let progress = Double(expenseCategory.spentCentsAtPeriod) / Double(plannedCentsAtPeriod)
        return progress > 1.0 ? 1.0 : progress
    }
    
    var isSpendingProgressCompleted: Bool {
        return spendingProgress == 1.0
    }
    
    var iconURL: URL? {
        return expenseCategory.iconURL
    }
    
    var isDeleted: Bool {
        return expenseCategory.deletedAt != nil
    }
    
    init(expenseCategory: ExpenseCategory) {
        self.expenseCategory = expenseCategory
    }
    
    func asHistoryTransactionFilter() -> ExpenseCategoryHistoryTransactionFilter {
        return ExpenseCategoryHistoryTransactionFilter(expenseCategoryViewModel: self)
    }
    
    func asIncludedInBalanceFilter() -> IncludedInBalanceHistoryTransactionFilter {
        return IncludedInBalanceHistoryTransactionFilter(expenseCategoryViewModel: self)
    }
    
    private func spent(shouldRound: Bool) -> String? {
        return expenseCategory.spentCentsAtPeriod.moneyCurrencyString(with: currency, shouldRound: shouldRound)
    }
}

extension ExpenseCategoryViewModel : TransactionCompletable {
    var amountRounded: String {
        return spentRounded ?? ""
    }
    
    @objc var amount: String {
        return spent ?? ""
    }
    
    func canComplete(startable: TransactionStartable) -> Bool {
        guard let startableExpenseSourceViewModel = startable as? ExpenseSourceViewModel else { return false }
        return !startableExpenseSourceViewModel.isDebt
    }
}
