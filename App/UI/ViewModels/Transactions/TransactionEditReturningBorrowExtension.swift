//
//  ReturningBorrowTransactionEditExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

extension TransactionEditViewModel {
    var returningBorrowId: Int? {
        return returningBorrow?.id
    }
    
    var isReturn: Bool {
        return returningBorrow != nil        
    }
    
    var isReturningDebt: Bool {
        return isReturn && returningBorrow!.isDebt
    }
    
    var isReturningLoan: Bool {
        return isReturn && returningBorrow!.isLoan
    }
    
    var sourceFilter: ExpenseSourcesFilter {
        return isReturningDebt
            ? ExpenseSourcesFilter.debts(currency: returningBorrow?.currency.code)
            : ExpenseSourcesFilter.noDebts
    }
    
    var destinationFilter: ExpenseSourcesFilter {
        return isReturningLoan
            ? ExpenseSourcesFilter.debts(currency: returningBorrow?.currency.code)
            : ExpenseSourcesFilter.noDebts
    }
    
    func loadReturningTransactionDefaults() -> Promise<Void> {
        return  firstly {
                    loadExpenseSources()
                }.then {
                    self.loadExchangeRate()
                }
    }
    
    func loadExpenseSources() -> Promise<Void> {
        guard isReturn, isNew else { return Promise.value(()) }
        
        return  firstly {
                    loadExpenseSourcesFromBorrowingTransaction()
                }.then {
                    self.loadDefaultDebtExpenseSourceIfNeeded()
                }.get {
                    func amountDebt(transactionable: Transactionable?) -> String? {
                        guard   let returningBorrow = self.returningBorrow,
                            transactionable?.currency.code == returningBorrow.currency.code else {
                                return nil
                        }
                        return returningBorrow.amountLeftDecimal
                    }
                    self.amount = amountDebt(transactionable: self.source)
                    self.convertedAmount = amountDebt(transactionable: self.destination)
                }
    }
    
    func loadExpenseSourcesFromBorrowingTransaction() -> Promise<Void> {
        guard   let returningBorrow = returningBorrow,
                let borrowingTransactionId = returningBorrow.borrowingTransactionId else { return Promise.value(()) }
        return  firstly {
                    loadTransaction(transactionId: borrowingTransactionId)
                }.then { borrowingTransaction in
                    self.loadTransactionablesFor(transaction: borrowingTransaction)
                }.get { _, source, destination in
                    self.setExpenseSourcesFromBorrowingTransaction(source: destination, destination: source)
                }.asVoid()
    }
        
    func setExpenseSourcesFromBorrowingTransaction(source: Transactionable, destination: Transactionable) -> Void {
        if !source.isDeleted {
            self.source = source
        }
        if !destination.isDeleted {
            self.destination = destination
        }
    }
    
    func loadDefaultDebtExpenseSourceIfNeeded() -> Promise<Void> {
        guard let returningBorrow = returningBorrow else { return Promise.value(()) }
        
        let shouldLoadDefaultSource = returningBorrow.isDebt && source == nil
        let shouldLoadDefaultDestination = returningBorrow.isLoan && destination == nil
        guard shouldLoadDefaultSource || shouldLoadDefaultDestination else { return Promise.value(()) }
        
        return  firstly {
                    expenseSourcesCoordinator.first(accountType: .debt, currency: returningBorrow.currency.code)
                }.get { expenseSource in
                    let debtExpenseSource = ExpenseSourceViewModel(expenseSource: expenseSource)
                    if shouldLoadDefaultSource {
                        self.source = debtExpenseSource
                    }
                    if shouldLoadDefaultDestination {
                        self.destination = debtExpenseSource
                    }
                }.asVoid()
    }
}

typealias ExpenseSourcesFilterOptions = (noDebts: Bool, accountType: AccountType?, currency: String?)

enum ExpenseSourcesFilter {
    case noDebts
    case debts(currency: String?)
    
    var options: ExpenseSourcesFilterOptions {
        switch self {
        case .noDebts:
            return (noDebts: true, accountType: nil, currency: nil)
        case .debts(let currency):
            return (noDebts: false, accountType: .debt, currency: currency)
        }
    }
}
