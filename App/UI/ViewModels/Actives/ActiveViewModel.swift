//
//  ActiveViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class ActiveViewModel : TransactionSource, TransactionDestination {
    let active: Active
    
    var isTransactionSource: Bool {
        return true
    }
    
    var id: Int {
        return active.id
    }
    
    var type: TransactionableType {
        return .active
    }
    
    var name: String {
        return active.name
    }
    
    var iconURL: URL? {
        return active.iconURL
    }
    
    var iconCategory: IconCategory? {
        switch active.basketType {
        case .joy:
            return IconCategory.expenseCategoryJoy
        case .safe:
            return IconCategory.expenseCategorySafe
        case .risk:
            return IconCategory.expenseCategoryRisk
        }
    }
    
    var currency: Currency {
        return active.currency
    }
    
    var amountRounded: String {
        return cost(shouldRound: true)
    }
    
    var amount: String {
        return cost(shouldRound: false)
    }
    
    var costRounded: String {
        return amountRounded
    }
    
    var cost: String {
        return amount
    }
    
    var investedRounded: String {
        return invested(shouldRound: true)
    }
    
    var invested: String {
        return invested(shouldRound: true)
    }
    
    var spentRounded: String {
        return spent(shouldRound: true)
    }
    
    var spent: String {
        return spent(shouldRound: true)
    }
    
    var boughtRounded: String {
        return bought(shouldRound: true)
    }
    
    var bought: String {
        return bought(shouldRound: true)
    }
    
    var planned: String {
        return money(cents: active.monthlyPaymentCents, shouldRound: false)
    }
    
    var areExpensesPlanned: Bool {
        guard let monthlyPaymentCents = active.monthlyPaymentCents else { return false }
        return monthlyPaymentCents > 0
    }
    
    var isMonthlyPaymentPlanCompleted: Bool {
        return spendingProgress == 1.0
    }
    
    var spendingProgress: Double {
        guard   areExpensesPlanned,
                let monthlyPaymentCents = active.monthlyPaymentCents else { return 0 }
        let progress = Double(active.investedCents) / Double(monthlyPaymentCents)
        return progress > 1.0 ? 1.0 : progress
    }
        
    var isDeleted: Bool {
        return active.deletedAt != nil
    }
    
    init(active: Active) {
        self.active = active
    }
    
    func isTransactionDestinationFor(transactionSource: TransactionSource) -> Bool {
        
        if let sourceExpenseSourceViewModel = transactionSource as? ExpenseSourceViewModel {
            return !sourceExpenseSourceViewModel.isDebt
        }
        
        if let sourceIncomeSourceViewModel = transactionSource as? IncomeSourceViewModel {
            return sourceIncomeSourceViewModel.incomeSource.activeId == self.id
        }
        
        return false
    }
    
    private func cost(shouldRound: Bool) -> String {
        return money(cents: active.costCents, shouldRound: shouldRound)
    }
    
    private func invested(shouldRound: Bool) -> String {
        return money(cents: active.investedCents, shouldRound: shouldRound)
    }
    
    private func bought(shouldRound: Bool) -> String {
        return money(cents: active.boughtCents, shouldRound: shouldRound)
    }
    
    private func spent(shouldRound: Bool) -> String {
        return money(cents: active.spentCents, shouldRound: shouldRound)
    }
    
    private func money(cents: Int?, shouldRound: Bool) -> String {
        return cents?.moneyCurrencyString(with: currency, shouldRound: shouldRound) ?? ""
    }
}
