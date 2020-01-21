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
    
    var isSelected: Bool = false
    
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
    
    var plannedAtPeriod: String? {
        return expenseCategory.plannedCentsAtPeriod?.moneyCurrencyString(with: currency, shouldRound: true)
    }
    
    var spentRounded: String? {
        return spent(shouldRound: true)
    }
    
    var spent: String? {
        return spent(shouldRound: false)
    }
        
    var profit: String? {
        return ""
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
       
    var isCredit: Bool {
        return expenseCategory.creditId != nil
    }
    
    var isBorrowOrReturn: Bool {
        return expenseCategory.isBorrowOrReturn
    }
    
    var creditId: Int? {
        return expenseCategory.creditId
    }
    
    var defaultIconName: String {
        return basketType.iconCategory.defaultIconName
    }
        
    public private(set) var waitingLoans: [BorrowViewModel] = []
    
    var hasWaitingLoans: Bool {
        return waitingLoans.count > 0
    }
    
    init(expenseCategory: ExpenseCategory) {
        self.expenseCategory = expenseCategory
        waitingLoans = expenseCategory.waitingLoans.map { BorrowViewModel(borrow: $0) }
    }
    
    func asTransactionFilter() -> ExpenseCategoryFilter {
        return ExpenseCategoryFilter(expenseCategoryViewModel: self)
    }
        
    private func spent(shouldRound: Bool) -> String? {
        return expenseCategory.spentCentsAtPeriod.moneyCurrencyString(with: currency, shouldRound: shouldRound)
    }
}

extension ExpenseCategoryViewModel : TransactionDestination {
    var type: TransactionableType {
        return .expenseCategory
    }
    
    var iconCategory: IconCategory? {
        return basketType.iconCategory
    }
    
    var amountRounded: String {
        return spentRounded ?? ""
    }
    
    @objc var amount: String {
        return spent ?? ""
    }
    
    func isTransactionDestinationFor(transactionSource: TransactionSource) -> Bool {
        return transactionSource is ExpenseSourceViewModel
    }
}
