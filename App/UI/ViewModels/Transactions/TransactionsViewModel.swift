//
//  TransactionsViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 27/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit
import SwifterSwift
import SwiftDate

class TransactionsViewModel {
    private let transactionsCoordinator: TransactionsCoordinatorProtocol
    private let creditsCoordinator: CreditsCoordinatorProtocol
    private let borrowsCoordinator: BorrowsCoordinatorProtocol
    private let exchangeRatesCoordinator: ExchangeRatesCoordinatorProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    private let currencyConverter: CurrencyConverterProtocol
    
    var defaultCurrency: Currency? = nil
    var defaultPeriod: AccountingPeriod? = nil
    var oldestTransactionGotAt: Date? = nil
    private var exchangeRates: [String : Float] = [String : Float]()
    
    private var allTransactionViewModels: [TransactionViewModel] = []
    public private(set) var filteredTransactionViewModels: [TransactionViewModel] = []
    
    var oldestTransactionDate: Date {
        return oldestTransactionGotAt ?? (Date().beginning(of: .month) ?? Date()) - 5.years
    }
        
    init(transactionsCoordinator: TransactionsCoordinatorProtocol,
         creditsCoordinator: CreditsCoordinatorProtocol,
         borrowsCoordinator: BorrowsCoordinatorProtocol,
         exchangeRatesCoordinator: ExchangeRatesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         currencyConverter: CurrencyConverterProtocol) {
        self.transactionsCoordinator = transactionsCoordinator
        self.creditsCoordinator = creditsCoordinator
        self.borrowsCoordinator = borrowsCoordinator
        self.exchangeRatesCoordinator = exchangeRatesCoordinator
        self.accountCoordinator = accountCoordinator
        self.currencyConverter = currencyConverter
    }
    
    func clearTransactions() {
        allTransactionViewModels = []
    }
    
    func loadData(dateRangeFilter: DateRangeTransactionFilter?) -> Promise<Void> {
        return when(fulfilled: loadDefaultCurrency(), loadTransactions(dateRangeFilter: dateRangeFilter), loadExchangeRates())
    }
    
    func loadTransactions(dateRangeFilter: DateRangeTransactionFilter?) -> Promise<Void> {
        return  firstly {
                    transactionsCoordinator.index(fromGotAt: dateRangeFilter?.fromDate, toGotAt: dateRangeFilter?.toDate)
                }.get { transactions in
                    self.allTransactionViewModels = transactions.map { TransactionViewModel(transaction: $0) }
                }.asVoid()
    }
    
    func filterTransactions(filters: [TransactionableFilter],
                            graphType: GraphType) {
        
        var transactionViewModels = allTransactionViewModels
        
        if filters.count > 0 {
            
            var filtersHash = [TransactionableType : [Int : TransactionableFilter]]()
            
            for filter in filters {
                if filtersHash[filter.type] == nil {
                    filtersHash[filter.type] = [Int : TransactionableFilter]()
                }
                filtersHash[filter.type]?[filter.id] = filter
            }
            
            transactionViewModels = transactionViewModels.filter { transaction -> Bool in
                
                if filtersHash[transaction.sourceType]?[transaction.sourceId] != nil {
                    return true
                }
                if filtersHash[transaction.destinationType]?[transaction.destinationId] != nil {
                    return true
                }
                if let sourceActiveId = transaction.sourceActiveId,
                    filtersHash[.active]?[sourceActiveId] != nil {
                    return true
                }
                if let sourceIncomeSourceId = transaction.sourceIncomeSourceId,
                    transaction.hasPositiveProfit,
                    transaction.type == .fundsMove,
                    transaction.destinationType == .expenseSource,
                    transaction.sourceType == .active,
                    filtersHash[.incomeSource]?[sourceIncomeSourceId] != nil {
                    return true
                }
                
                return false
            }
        }
                
        func filterBy(graphType: GraphType, transactions: [TransactionViewModel]) -> [TransactionViewModel] {
            switch graphType {
            case .all:
                return transactions
            case .incomes:
                return transactions.filter { $0.type == .income || $0.hasPositiveProfit }
            case .expenses:
                return transactions.filter { $0.type == .expense || $0.hasNegativeProfit }
            }
        }
        
        filteredTransactionViewModels = filterBy(graphType: graphType, transactions: transactionViewModels)
    }
    
    func removeTransaction(transactionViewModel: TransactionViewModel) -> Promise<Void> {        
        if let creditId = transactionViewModel.creditId {
            return creditsCoordinator.destroyCredit(by: creditId, deleteTransactions: true)
        }
        if let borrowId = transactionViewModel.borrowId, transactionViewModel.isBorrowing {
            return transactionViewModel.isDebt
                ? borrowsCoordinator.destroyDebt(by: borrowId, deleteTransactions: true)
                : borrowsCoordinator.destroyLoan(by: borrowId, deleteTransactions: true)
        }
        return transactionsCoordinator.destroy(by: transactionViewModel.id)
    }
    
    func duplicateTransaction(transactionViewModel: TransactionViewModel) -> Promise<Void> {
        return transactionsCoordinator.duplicate(by: transactionViewModel.id)
    }
    
    private func loadDefaultCurrency() -> Promise<Void> {
        return  firstly {
                    accountCoordinator.loadCurrentUser()
                }.get { user in
                    self.defaultCurrency = user.currency
                    self.defaultPeriod = user.defaultPeriod
                    self.oldestTransactionGotAt = user.oldestTransactionGotAt
                }.asVoid()
    }
    
    private func loadExchangeRates() -> Promise<Void> {
        return  firstly {
                    exchangeRatesCoordinator.index()
                }.get { rates in
                    self.exchangeRates = [String : Float]()
                    
                    for exchangeRate in rates {
                        self.exchangeRates[exchangeRate.from] = exchangeRate.rate
                    }
                }.asVoid()
    }
            
    func transactionsAmount(transactions: [TransactionViewModel]) -> NSDecimalNumber {
        guard let currency = defaultCurrency else { return 0.0 }
        
        return transactions
            .map { transaction -> NSDecimalNumber in
                return transaction.amount(matching: currency) ?? convert(cents: transaction.calculatingAmountCents,
                                                                         from: transaction.calculatingCurrency,
                                                                         to: currency)
            }
            .reduce(0, +)
    }
    
    private func convert(cents: Int, from: Currency, to: Currency) -> NSDecimalNumber {
        
        guard let exchangeRate = exchangeRates[from.code] else { return 0 }
        
        return currencyConverter.convert(cents: cents,
                                         fromCurrency: from,
                                         toCurrency: to,
                                         exchangeRate: Double(exchangeRate),
                                         forward: true)
    }    
}
