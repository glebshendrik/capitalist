//
//  TransactionEditLoadingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

// Loading
extension TransactionEditViewModel {    
    func loadDefaults() -> Promise<Void> {
        if isReturn {
            return loadReturningTransactionDefaults()
        }
        if let requiredTransactionType = requiredTransactionType {
            return  firstly {
                        loadTransactionables(requiredTransactionType: requiredTransactionType)
                    }.then {
                        self.loadExchangeRate()
                    }
        }
        return loadExchangeRate()
    }
    
    func loadTransactionables(requiredTransactionType: TransactionType) -> Promise<Void> {
        var promises: [Promise<Void>] = []
        switch requiredTransactionType {
        case .income:
            if source       == nil { promises.append(loadSource(type: .incomeSource)) }
            if destination  == nil { promises.append(loadDestination(type: .expenseSource)) }
        case .expense:
            if source       == nil { promises.append(loadSource(type: .expenseSource)) }
            if destination  == nil { promises.append(loadDestination(type: .expenseCategory)) }
        case .fundsMove:
            if source == nil && destination == nil {
                promises.append(loadSource(type: .expenseSource, index: 0))
                promises.append(loadDestination(type: .expenseSource, index: 1))
            }
            else {
                if source       == nil { promises.append(loadSource(type: .expenseSource)) }
                if destination  == nil { promises.append(loadDestination(type: .expenseSource)) }
            }
        }
        return when(fulfilled: promises)
    }
    
    func loadTransactionData() -> Promise<Void> {
        guard let transactionId = transactionId else {
            return Promise(error: TransactionError.transactionIsNotSpecified)
        }
        return  firstly {
                    loadTransaction(transactionId: transactionId)
                }.then { transaction in
                    self.loadTransactionablesFor(transaction: transaction)
                }.get { transaction, source, destination in
                    self.set(transaction: transaction, source: source, destination: destination)
                }.then { _ in
                    self.loadExchangeRate()
                }
    }
    
    func loadTransaction(transactionId: Int) -> Promise<Transaction> {
        return transactionsCoordinator.show(by: transactionId)
    }
    
    func loadTransactionablesFor(transaction: Transaction) -> Promise<(Transaction, Transactionable, Transactionable)> {
        return loadTransactionables(sourceId: transaction.sourceId,
                                    sourceType: transaction.sourceType,
                                    destinationId: transaction.destinationId,
                                    destinationType: transaction.destinationType)
                .map { (transaction, $0.0, $0.1) }
    }
    
    func loadTransactionables(sourceId: Int,
                              sourceType: TransactionableType,
                              destinationId: Int,
                              destinationType: TransactionableType) -> Promise<(Transactionable, Transactionable)> {
        
        return  when(fulfilled: loadTransactionable(id: sourceId, type: sourceType),
                                loadTransactionable(id: destinationId, type: destinationType))
    }
    
    func loadTransactionable(id: Int, type: TransactionableType) -> Promise<Transactionable> {
        switch type {
        case .incomeSource:         return loadIncomeSource(id: id)
        case .expenseSource:        return loadExpenseSource(id: id)
        case .expenseCategory:      return loadExpenseCategory(id: id)
        case .active:               return loadActive(id: id)
        }
    }
    
    func loadIncomeSource(id: Int) -> Promise<Transactionable> {
        return  firstly {
                    incomeSourcesCoordinator.show(by: id)
                }.map { incomeSource in
                    IncomeSourceViewModel(incomeSource: incomeSource)
                }
    }
    
    func loadExpenseSource(id: Int) -> Promise<Transactionable> {
        return  firstly {
                    expenseSourcesCoordinator.show(by: id)
                }.map { expenseSource in
                    ExpenseSourceViewModel(expenseSource: expenseSource)
                }
    }
    
    func loadExpenseCategory(id: Int) -> Promise<Transactionable> {
        return  firstly {
                    expenseCategoriesCoordinator.show(by: id)
                }.map { expenseCategory in
                    ExpenseCategoryViewModel(expenseCategory: expenseCategory)
                }
    }
    
    func loadActive(id: Int) -> Promise<Transactionable> {
        return  firstly {
                    activesCoordinator.showActive(by: id)
                }.map { active in
                    ActiveViewModel(active: active)
                }
    }
    
    func loadTransactionable(type: TransactionableType, basketType: BasketType = .joy, index: Int = 0) -> Promise<Transactionable?> {
        switch type {
        case .incomeSource:         return loadIncomeSource(index: index)
        case .expenseSource:        return loadExpenseSource(index: index)
        case .expenseCategory:      return loadExpenseCategory(basketType: basketType, index: index)
        case .active:               return loadActive(basketType: basketType, index: index)
        }
    }
    
    func loadIncomeSource(index: Int = 0) -> Promise<Transactionable?> {
        return  firstly {
                    incomeSourcesCoordinator.index(noBorrows: true)
                }.map { incomeSources in
                    guard let incomeSource = incomeSources[safe: index] else { return nil }
                    return IncomeSourceViewModel(incomeSource: incomeSource)
                }
    }
    
    func loadExpenseSource(index: Int = 0) -> Promise<Transactionable?> {
        return  firstly {
                    expenseSourcesCoordinator.index(currency: nil)
                }.map { expenseSources in
                    let expenseSourceViewModels = expenseSources.map { ExpenseSourceViewModel(expenseSource: $0) }
                                                                .filter { !$0.accountConnected }
                    return expenseSourceViewModels[safe: index]
                }
    }
    
    func loadExpenseCategory(basketType: BasketType, index: Int = 0) -> Promise<Transactionable?> {
        return  firstly {
                    expenseCategoriesCoordinator.index(for: basketType, noBorrows: true)
                }.map { expenseCategories in
                    guard let expenseCategory = expenseCategories[safe: index] else { return nil }
                    return ExpenseCategoryViewModel(expenseCategory: expenseCategory)
                }
    }
    
    func loadActive(basketType: BasketType, index: Int = 0) -> Promise<Transactionable?> {
        return  firstly {
                    activesCoordinator.indexActives(for: basketType)
                }.map { actives in
                    guard let active = actives[safe: index] else { return nil }
                    return ActiveViewModel(active: active)
                }
    }
    
    func loadExchangeRate() -> Promise<Void> {
        guard   needCurrencyExchange,
            let sourceCurrencyCode = sourceCurrencyCode,
            let destinationCurrencyCode = destinationCurrencyCode else {
                if self.returningBorrow != nil && isNew {
                    self.setBorrowLeftAmounts()
                }
                return Promise.value(())
        }
        return  firstly {
                    exchangeRatesCoordinator.show(from: sourceCurrencyCode, to: destinationCurrencyCode)
                }.done { exchangeRate in
                    self.exchangeRate = exchangeRate.rate
                    if self.returningBorrow != nil && self.isNew {
                        self.setBorrowLeftAmounts()
                    }                    
                }
    }
    
    func loadSource(id: Int, type: TransactionableType) -> Promise<Void> {
        return  firstly {
                    loadTransactionable(id: id, type: type)
                }.get { transactionable in
                    self.source = transactionable
                }.asVoid()
    }
    
    func loadDestination(id: Int, type: TransactionableType) -> Promise<Void> {
        return  firstly {
                    loadTransactionable(id: id, type: type)
                }.get { transactionable in
                    self.destination = transactionable
                }.asVoid()
    }
    
    func loadSource(type: TransactionableType, basketType: BasketType = .joy, index: Int = 0) -> Promise<Void> {
        return  firstly {
                    loadTransactionable(type: type, basketType: basketType, index: index)
                }.get { transactionable in
                    self.source = transactionable
                }.asVoid()
    }
    
    func loadDestination(type: TransactionableType, basketType: BasketType = .joy, index: Int = 0) -> Promise<Void> {
        return  firstly {
                    loadTransactionable(type: type, basketType: basketType, index: index)
                }.get { transactionable in
                    self.destination = transactionable
                }.asVoid()
    }
}

// Creation
extension TransactionEditViewModel {
    func create() -> Promise<Void> {
        return  firstly {
                    transactionsCoordinator.create(with: creationForm())
                }.done { transaction in
                    self.transaction = transaction
                }.asVoid()
    }
    
    func isCreationFormValid() -> Bool {
        return creationForm().validate() == nil
    }
    
    private func creationForm() -> TransactionCreationForm {
        return TransactionCreationForm(userId: userId,
                                       sourceId: sourceId,
                                       sourceType: sourceType,
                                       destinationId: destinationId,
                                       destinationType: destinationType,
                                       amountCents: amountCents,
                                       amountCurrency: amountCurrency,
                                       convertedAmountCents: convertedAmountCents,
                                       convertedAmountCurrency: convertedAmountCurrency,
                                       gotAt: gotAt ?? Date(),
                                       comment: comment,
                                       returningBorrowId: returningBorrowId,
                                       isBuyingAsset: isBuyingAsset)
    }
}

// Updating
extension TransactionEditViewModel {
    func update() -> Promise<Void> {
        return transactionsCoordinator.update(with: updatingForm())
    }
    
    func isUpdatingFormValid() -> Bool {
        return updatingForm().validate() == nil
    }
    
    private func updatingForm() -> TransactionUpdatingForm {
        return TransactionUpdatingForm(id: transactionId,
                                       sourceId: sourceId,
                                       sourceType: sourceType,
                                       destinationId: destinationId,
                                       destinationType: destinationType,
                                       amountCents: amountCents,
                                       amountCurrency: amountCurrency,
                                       convertedAmountCents: convertedAmountCents,
                                       convertedAmountCurrency: convertedAmountCurrency,
                                       gotAt: gotAt,
                                       comment: comment)
    }
}

// Removing
extension TransactionEditViewModel {
    func removeTransaction() -> Promise<Void> {
        guard let transactionId = transaction?.id else {
            return Promise(error: TransactionError.transactionIsNotSpecified)
        }
        return transactionsCoordinator.destroy(by: transactionId)
    }
}
