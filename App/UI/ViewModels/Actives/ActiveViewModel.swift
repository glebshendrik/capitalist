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
        return amount(shouldRound: true)
    }
    
    var amount: String {
        return amount(shouldRound: false)
    }
    
    var costRounded: String {
        return amountRounded
    }
    
    var cost: String {
        return amount
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
    
    private func amount(shouldRound: Bool) -> String {
        return active.costCents.moneyCurrencyString(with: currency, shouldRound: shouldRound) ?? ""
    }
}
