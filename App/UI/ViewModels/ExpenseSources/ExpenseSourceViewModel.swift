//
//  ExpenseSourceViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 25/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation

class ExpenseSourceViewModel {
    public private(set) var expenseSource: ExpenseSource
    
    var id: Int {
        return expenseSource.id
    }
    
    var name: String {
        return expenseSource.name
    }
    
    var amountRounded: String {
        return amount(shouldRound: true)
    }
    
    var amount: String {
        return amount(shouldRound: false)
    }
    
    var inCredit: Bool {
        guard let creditLimitCents = expenseSource.creditLimitCents else { return false }
        return expenseSource.amountCents < creditLimitCents
    }
    
    var creditCents: Int? {
        guard let creditLimitCents = expenseSource.creditLimitCents else { return nil }
        return creditLimitCents - expenseSource.amountCents
    }
    
    var credit: String? {
        return creditCents?.moneyCurrencyString(with: currency, shouldRound: true)
    }
    
    var creditLimit: String? {
        return expenseSource.creditLimitCents?.moneyCurrencyString(with: currency, shouldRound: true)
    }
    
    var currency: Currency {
        return expenseSource.currency
    }
    
    var iconURL: URL? {
        return expenseSource.iconURL
    }
    
    var isDeleted: Bool {
        return expenseSource.deletedAt != nil
    }
    
    var isVirtual: Bool {
        return expenseSource.isVirtual
    }
    
    var defaultIconName: String {
        return IconCategory.expenseSource.defaultIconName
    }
    
    init(expenseSource: ExpenseSource) {
        self.expenseSource = expenseSource
    }
    
    func asTransactionFilter() -> ExpenseSourceTransactionFilter {
        return ExpenseSourceTransactionFilter(expenseSourceViewModel: self)
    }
    
    private func amount(shouldRound: Bool) -> String {
        return expenseSource.amountCents.moneyCurrencyString(with: currency, shouldRound: shouldRound) ?? ""
    }
}

extension ExpenseSourceViewModel : TransactionSource, TransactionDestination {
    var type: TransactionableType {
        return .expenseSource
    }
    
    var iconCategory: IconCategory? {
        return IconCategory.expenseSource
    }
    
    var isTransactionSource: Bool {
        return true
    }
    
    func isTransactionDestinationFor(transactionSource: TransactionSource) -> Bool {
        if let sourceExpenseSourceViewModel = transactionSource as? ExpenseSourceViewModel {
            return sourceExpenseSourceViewModel.id != self.id
        }
        
        return (transactionSource is IncomeSourceViewModel) || (transactionSource is ActiveViewModel)
    }
}
