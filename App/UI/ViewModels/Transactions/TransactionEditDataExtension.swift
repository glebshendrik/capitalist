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
        return isReturn ? loadReturningTransactionDefaults() : loadExchangeRate()
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
    
    func loadExchangeRate() -> Promise<Void> {
        guard   needCurrencyExchange,
            let sourceCurrencyCode = sourceCurrencyCode,
            let destinationCurrencyCode = destinationCurrencyCode else {
                return Promise.value(())
        }
        return  firstly {
                    exchangeRatesCoordinator.show(from: sourceCurrencyCode, to: destinationCurrencyCode)
                }.done { exchangeRate in
                    self.exchangeRate = exchangeRate.rate
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
}

// Creation
extension TransactionEditViewModel {
    func deleteAsset() -> Promise<Void> {
        guard   let assetId = self.sourceId,
                let sourceType = sourceType,
                let destinationType = destinationType,
                sourceType == .active,
                destinationType == .expenseSource else { return Promise.value(()) }
        return activesCoordinator.destroyActive(by: assetId, deleteTransactions: false)
    }
}

// Creation
extension TransactionEditViewModel {
    func create() -> Promise<Void> {
        return  firstly {
                    transactionsCoordinator.create(with: creationForm())
                }.then { [weak self] transaction -> Promise<Void> in
                    self?.transaction = transaction
                    guard let weakSelf = self,
                          weakSelf.isSellingAsset else { return Promise.value(()) }
                    
                    return weakSelf.deleteAsset()
                }
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
