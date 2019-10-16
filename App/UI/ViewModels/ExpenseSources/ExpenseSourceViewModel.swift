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
        guard let creditLimitCents = expenseSource.creditLimitCents, isUsual else { return false }
        return expenseSource.amountCents < creditLimitCents
    }
    
    var creditCents: Int? {
        guard let creditLimitCents = expenseSource.creditLimitCents else { return nil }
        return creditLimitCents - expenseSource.amountCents
    }
    
    var credit: String? {
        return creditCents?.moneyCurrencyString(with: currency, shouldRound: true)
    }
    
    var currency: Currency {
        return expenseSource.currency
    }
    
    var iconURL: URL? {
        return expenseSource.iconURL
    }
    
    var isDebt: Bool {
        return expenseSource.accountType == .debt
    }
    
    var isGoal: Bool {
        return expenseSource.accountType == .goal
    }
    
    var isUsual: Bool {
        return expenseSource.accountType == .usual
    }
    
    var goalProgress: Double {
        guard isGoal, let goalAmountCents = expenseSource.goalAmountCents else { return 0 }
        let progress = Double(expenseSource.amountCents) / Double(goalAmountCents)
        return progress > 1.0 ? 1.0 : progress
    }
    
    var isGoalCompleted: Bool {
        return goalProgress == 1.0
    }
    
    var isDeleted: Bool {
        return expenseSource.deletedAt != nil
    }
    
    public private(set) var waitingDebts: [BorrowViewModel] = []
    public private(set) var waitingLoans: [BorrowViewModel] = []
    
    var hasWaitingDebts: Bool {
        return waitingDebts.count > 0
    }
    
    var hasWaitingLoans: Bool {
        return waitingLoans.count > 0
    }
    
    var defaultIconName: String {
        return expenseSource.accountType.iconCategory.defaultIconName
    }
    
    init(expenseSource: ExpenseSource) {
        self.expenseSource = expenseSource
        waitingDebts = expenseSource.waitingDebts?.map { BorrowViewModel(borrow: $0) } ?? []
        waitingLoans = expenseSource.waitingLoans?.map { BorrowViewModel(borrow: $0) } ?? []
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
        return expenseSource.accountType.iconCategory
    }
    
    var isTransactionSource: Bool {
        return !isGoal || isGoalCompleted
    }
    
    func isTransactionDestinationFor(transactionSource: TransactionSource) -> Bool {
        if let sourceExpenseSourceViewModel = transactionSource as? ExpenseSourceViewModel {
            return  sourceExpenseSourceViewModel.id != self.id &&
                    !(sourceExpenseSourceViewModel.isDebt && self.isDebt)
        }
        
        return (transactionSource is IncomeSourceViewModel) && !self.isDebt
    }
}
