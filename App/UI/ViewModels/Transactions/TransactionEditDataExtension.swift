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
            if source       == nil { promises.append(loadSource(type: .expenseSource)) }
            if destination  == nil { promises.append(loadDestination(type: .expenseSource)) }
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
    
    func loadFirstTransactionable(type: TransactionableType, basketType: BasketType = .joy) -> Promise<Transactionable?> {
        switch type {
        case .incomeSource:         return loadFirstIncomeSource()
        case .expenseSource:        return loadFirstExpenseSource()
        case .expenseCategory:      return loadFirstExpenseCategory(basketType: basketType)
        case .active:               return loadFirstActive(basketType: basketType)
        }
    }
    
    func loadFirstIncomeSource() -> Promise<Transactionable?> {
        return  firstly {
                    incomeSourcesCoordinator.first(noBorrows: true)
                }.map { incomeSource in
                    guard let incomeSource = incomeSource else { return nil }
                    return IncomeSourceViewModel(incomeSource: incomeSource)
                }
    }
    
    func loadFirstExpenseSource() -> Promise<Transactionable?> {
        return  firstly {
                    expenseSourcesCoordinator.first()
                }.map { expenseSource in
                    guard let expenseSource = expenseSource else { return nil }
                    return ExpenseSourceViewModel(expenseSource: expenseSource)
                }
    }
    
    func loadFirstExpenseCategory(basketType: BasketType) -> Promise<Transactionable?> {
        return  firstly {
                    expenseCategoriesCoordinator.first(for: basketType, noBorrows: true)
                }.map { expenseCategory in
                    guard let expenseCategory = expenseCategory else { return nil }
                    return ExpenseCategoryViewModel(expenseCategory: expenseCategory)
                }
    }
    
    func loadFirstActive(basketType: BasketType) -> Promise<Transactionable?> {
        return  firstly {
                    activesCoordinator.first(for: basketType)
                }.map { active in
                    guard let active = active else { return nil }
                    return ActiveViewModel(active: active)
                }
    }
    
    func loadExchangeRate() -> Promise<Void> {
        guard   needCurrencyExchange,
            let sourceCurrencyCode = sourceCurrencyCode,
            let destinationCurrencyCode = destinationCurrencyCode else {
                if self.returningBorrow != nil {
                    self.setAmounts()
                }
                return Promise.value(())
        }
        return  firstly {
                    exchangeRatesCoordinator.show(from: sourceCurrencyCode, to: destinationCurrencyCode)
                }.done { exchangeRate in
                    self.exchangeRate = exchangeRate.rate
                    if self.returningBorrow != nil {
                        self.setAmounts()
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
    
    func loadSource(type: TransactionableType, basketType: BasketType = .joy) -> Promise<Void> {
        return  firstly {
                    loadFirstTransactionable(type: type, basketType: basketType)
                }.get { transactionable in
                    self.source = transactionable
                }.asVoid()
    }
    
    func loadDestination(type: TransactionableType, basketType: BasketType = .joy) -> Promise<Void> {
        return  firstly {
                    loadFirstTransactionable(type: type, basketType: basketType)
                }.get { transactionable in
                    self.destination = transactionable
                }.asVoid()
    }
    
    func load(sourceType: TransactionableType, destinationType: TransactionableType, sourceBasketType: BasketType = .safe, destinationBasketType: BasketType = .joy) -> Promise<Void> {
        return  firstly {
                    when(fulfilled: loadFirstTransactionable(type: sourceType, basketType: sourceBasketType),
                                    loadFirstTransactionable(type: destinationType, basketType: destinationBasketType))
            
                }.get { source, destination in
                    self.source = source
                    self.destination = destination
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
