//
//  TransactionEditViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 27/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum TransactionError : Error {
    case transactionIsNotSpecified
    case canNotLoadExpenseSource
}

class TransactionEditViewModel {
    let exchangeRatesCoordinator: ExchangeRatesCoordinatorProtocol
    let currencyConverter: CurrencyConverterProtocol
    let transactionsCoordinator: TransactionsCoordinatorProtocol
    let accountCoordinator: AccountCoordinatorProtocol
    let incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol
    let expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol
    let expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol
    let activesCoordinator: ActivesCoordinatorProtocol
    
    var transactionId: Int?
    var transaction: Transaction? = nil
    var returningBorrow: BorrowViewModel?

    var source: Transactionable? = nil { didSet { didSetSource(oldValue) } }
    var destination: Transactionable? = nil { didSet { didSetDestination(oldValue) } }
    var amount: String? = nil { didSet { didSetAmount() } }
    var convertedAmount: String? = nil { didSet { didSetConvertedAmount() } }    
    var comment: String? = nil
    var gotAt: Date? = nil
    var isBuyingAsset: Bool = false
    var isSellingAsset: Bool = false
    var amountConverted: String? = nil
    var convertedAmountConverted: String? = nil
    var exchangeRate: Float = 1.0 { didSet { didSetExchangeRate() } }
    var accumulator: Int? = nil
    var previousOperation: OperationType? = nil
    var requiredTransactionType: TransactionType? = nil
    var isSourceInitiallyConnected: Bool = false
    var isDestinationInitiallyConnected: Bool = false
    
    init(transactionsCoordinator: TransactionsCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol,
         expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol,
         expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol,
         activesCoordinator: ActivesCoordinatorProtocol,
         exchangeRatesCoordinator: ExchangeRatesCoordinatorProtocol,
         currencyConverter: CurrencyConverterProtocol) {
        self.transactionsCoordinator = transactionsCoordinator
        self.accountCoordinator = accountCoordinator
        self.incomeSourcesCoordinator = incomeSourcesCoordinator
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
        self.expenseCategoriesCoordinator = expenseCategoriesCoordinator
        self.activesCoordinator = activesCoordinator
        self.exchangeRatesCoordinator = exchangeRatesCoordinator
        self.currencyConverter = currencyConverter
    }
    
    func set(transactionId: Int, transactionType: TransactionType?) {
        self.transactionId = transactionId
        self.requiredTransactionType = transactionType
    }
    
    func set(source: Transactionable?, destination: Transactionable?, returningBorrow: BorrowViewModel?, transactionType: TransactionType?) {
        self.returningBorrow = returningBorrow
        self.source = source
        self.destination = destination
        if let destination = destination as? ActiveViewModel {
            self.isBuyingAsset = destination.activeType.buyingAssetsDefault
        }
        self.requiredTransactionType = transactionType
    }
        
    func set(transaction: Transaction, source: Transactionable, destination: Transactionable) {
        self.transaction = transaction
        self.comment = transaction.comment
        self.gotAt = transaction.gotAt
        self.isBuyingAsset = transaction.isBuyingAsset
        if let returningBorrow = transaction.returningBorrow {
            self.returningBorrow = BorrowViewModel(borrow: returningBorrow)
        }
        self.source = source
        self.destination = destination
        self.isSourceInitiallyConnected = isRemoteTransaction && (source as? ExpenseSourceViewModel)?.accountViewModel?.account.id == transaction.accountId
        self.isDestinationInitiallyConnected = isRemoteTransaction && (destination as? ExpenseSourceViewModel)?.accountViewModel?.account.id == transaction.accountId
        self.amount = transaction.amountCents.moneyDecimalString(with: sourceCurrency)
        self.convertedAmount = transaction.convertedAmountCents.moneyDecimalString(with: destinationCurrency)
    }
    
    func save() -> Promise<Void> {
        return isNew ? create() : update()
    }
    
    func remove() -> Promise<Void> {
        return removeTransaction()
    }
    
    func loadData() -> Promise<Void> {
        return isNew ? loadDefaults() : loadTransactionData()
    }
    
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
}
