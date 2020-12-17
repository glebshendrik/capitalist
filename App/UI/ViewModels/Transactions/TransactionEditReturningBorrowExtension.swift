//
//  ReturningBorrowTransactionEditExtension.swift
//  Capitalist
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
    
    var sourceFilterCurrency: String? {
        return isReturningDebt
            ? returningBorrow?.currency.code
            : nil
    }

    var destinationFilterCurrency: String? {
        return isReturningLoan
            ? returningBorrow?.currency.code
            : nil
    }
    
    func loadReturningTransactionDefaults() -> Promise<Void> {
        return  firstly {
                    loadReturningTransactionablesIfNeeded()
                }.get {
                    self.setBorrowLeftAmounts()
                }.then {
                    self.loadExchangeRate()
                }
    }
    
    func loadReturningTransactionablesIfNeeded() -> Promise<Void> {
        guard isReturn, isNew else { return Promise.value(()) }
        
        return  firstly {
                    loadExpenseSourceFromBorrowingTransaction()
                }.then { expenseSource in
                    return when(fulfilled:  self.loadSourceIfNeeded(borrowingTransactionExpenseSource: expenseSource),
                                            self.loadDestinationIfNeeded(borrowingTransactionExpenseSource: expenseSource))
                }.get { source, destination in
                    self.setTransactionablesFromBorrowingTransaction(source: source, destination: destination)
                }.asVoid()
    }
    
    func loadExpenseSourceFromBorrowingTransaction() -> Promise<ExpenseSourceViewModel?> {
        guard   let returningBorrow = returningBorrow,
            let borrowingTransactionId = returningBorrow.borrowingTransactionId else { return Promise.value(nil) }
        return  firstly {
                    loadTransaction(transactionId: borrowingTransactionId)
                }.then { borrowingTransaction -> Promise<ExpenseSource> in
                    if borrowingTransaction.sourceType == .expenseSource {
                        return self.expenseSourcesCoordinator.show(by: borrowingTransaction.sourceId)
                    } else {
                        return self.expenseSourcesCoordinator.show(by: borrowingTransaction.destinationId)
                    }
                }.then { expenseSource in
                    return expenseSource.isVirtual
                        ? self.expenseSourcesCoordinator.first(currency: expenseSource.currency.code, isVirtual: false)
                        : Promise.value(expenseSource)
                }.map { expenseSource in
                    return ExpenseSourceViewModel(expenseSource: expenseSource)
                }
    }
        
    func loadSourceIfNeeded(borrowingTransactionExpenseSource: ExpenseSourceViewModel?) -> Promise<Transactionable?> {
        guard source == nil else { return Promise.value(source) }
        guard let returningBorrow = returningBorrow else { return Promise.value(nil) }
        
        if returningBorrow.isLoan {
            return Promise.value(borrowingTransactionExpenseSource)
        }
        return loadBorrowIncomeSource(currency: returningBorrow.currency.code)
        
    }
    
    func loadDestinationIfNeeded(borrowingTransactionExpenseSource: ExpenseSourceViewModel?) -> Promise<Transactionable?> {
        guard destination == nil else { return Promise.value(destination) }
        guard let returningBorrow = returningBorrow else { return Promise.value(nil) }
        
        if returningBorrow.isDebt {
            return Promise.value(borrowingTransactionExpenseSource)
        }
        return loadBorrowExpenseCategory(currency: returningBorrow.currency.code)
        
    }
    
    func loadBorrowIncomeSource(currency: String) -> Promise<Transactionable?> {
        return  firstly {
                    incomeSourcesCoordinator.firstBorrow(currency: currency)
                }.map { incomeSource -> Transactionable? in
                    return IncomeSourceViewModel(incomeSource: incomeSource)
                }
    }
        
    func loadBorrowExpenseCategory(currency: String) -> Promise<Transactionable?> {
        return  firstly {
                    expenseCategoriesCoordinator.firstBorrow(for: .joy, currency: currency)
                }.map { expenseCategory -> Transactionable? in
                    return ExpenseCategoryViewModel(expenseCategory: expenseCategory)
                }
    }
    
    func setTransactionablesFromBorrowingTransaction(source: Transactionable?, destination: Transactionable?) -> Void {
        if let source = source, !source.isDeleted {
            self.source = source
        }
        if let destination = destination, !destination.isDeleted {
            self.destination = destination
        }
    }
    
    func setBorrowLeftAmounts() {
        func amountDebt(transactionable: Transactionable?) -> String? {
            guard   let returningBorrow = returningBorrow,
                    transactionable?.currency.code == returningBorrow.currency.code else {
                    return nil
            }
            return returningBorrow.amountLeftDecimal
        }
        amount = amountDebt(transactionable: source)
        convertedAmount = amountDebt(transactionable: destination)
    }
}
