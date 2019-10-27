//
//  TransactionEditViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 27/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum TransactionError : Error {
    case transactionIsNotSpecified
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
    var isBuyingAsset: Bool = true
    var amountConverted: String? = nil
    var convertedAmountConverted: String? = nil
    var exchangeRate: Float = 1.0 { didSet { didSetExchangeRate() } }
    
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
    
    func set(transactionId: Int) {
        self.transactionId = transactionId
    }
    
    func set(source: Transactionable?, destination: Transactionable?, returningBorrow: BorrowViewModel?) {
        self.returningBorrow = returningBorrow
        self.source = source
        self.destination = destination
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
        self.amount = transaction.amountCents.moneyDecimalString(with: sourceCurrency)
        self.convertedAmount = transaction.convertedAmountCents.moneyDecimalString(with: destinationCurrency)
    }
    
    func loadData() -> Promise<Void> {
        return isNew ? loadDefaults() : loadTransactionData()
    }
    
    func save() -> Promise<Void> {
        return isNew ? create() : update()
    }
    
    func remove() -> Promise<Void> {
        return removeTransaction()
    }
}
