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
    
    private var allCurrencyCodes: [String] = []
    var defaultCurrency: Currency? = nil
    var defaultPeriod: AccountingPeriod? = nil
    var oldestTransactionGotAt: Date? = nil
    private var exchangeRates: [String : Float] = [String : Float]()
    
    public private(set) var filteredTransactionViewModels: [TransactionViewModel] = []
    
    private var allTransactionViewModels: [TransactionViewModel] = [] {
        didSet {
            let currencies = allTransactionViewModels.map { $0.currency.code }.withoutDuplicates()
            let convertedCurrencies = allTransactionViewModels.map { $0.convertedCurrency.code }.withoutDuplicates()
            allCurrencyCodes = (currencies + convertedCurrencies).withoutDuplicates()
        }
    }
    
    var oldestTransactionDate: Date {
        return oldestTransactionGotAt ?? (Date().beginning(of: .month) ?? Date()) - 5.years
    }
    
    var hasIncomeTransactions: Bool {
        return filteredTransactionViewModels.any { $0.sourceType == .incomeSource }
    }
    
    var hasExpenseTransactions: Bool {
        return filteredTransactionViewModels.any { $0.destinationType == .expenseCategory }
    }
    
    var filteredIncomesAmount: String? {
        return transactionsAmount(type: .incomeSource)
    }
    
    var filteredExpensesAmount: String? {
        return transactionsAmount(type: .expenseCategory)
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
    
    func loadData(dateRangeFilter: DateRangeTransactionFilter?) -> Promise<Void> {
        return  firstly {
                    when(fulfilled: loadDefaultCurrency(), loadTransactions(dateRangeFilter: dateRangeFilter))
                }.then {
                    self.loadExchangeRates()
                }
    }
    
    func clearTransactions() {
        allTransactionViewModels = []
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
                
                guard let matchedFilter = (filtersHash[transaction.sourceType]?[transaction.sourceId] ??
                    filtersHash[transaction.destinationType]?[transaction.destinationId]) else { return false }
                
                return true
            }
        }
        
//        if let fromDate = dateRangeFilter?.fromDate {
//            transactionViewModels = transactionViewModels.filter {
//                $0.gotAt >= fromDate
//            }
//        }
//
//        if let toDate = dateRangeFilter?.toDate {
//            transactionViewModels = transactionViewModels.filter {
//                $0.gotAt <= toDate
//            }
//        }
        
        func filterBy(graphType: GraphType, transactions: [TransactionViewModel]) -> [TransactionViewModel] {
            switch graphType {
            case .all:
                return transactions
            case .incomes:
                return transactions.filter { $0.type == .income }
            case .expenses:
                return transactions.filter { $0.type == .expense }
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
//        guard let defaultCurrencyCode = defaultCurrency?.code else {
//            return Promise(error: StatisticsError.exchangeRateUnknown)
//        }
//        let fromCurrencyCodes = allCurrencyCodes.filter { $0 != defaultCurrencyCode }
        return  firstly {
                    exchangeRatesCoordinator.index()
//                    when(fulfilled: fromCurrencyCodes.map { loadExchangeRate(fromCurrencyCode: $0,
//                                                                     toCurrencyCode: defaultCurrencyCode)} )
                }.get { rates in
                    self.exchangeRates = [String : Float]()
                    
                    for exchangeRate in rates {
                        self.exchangeRates[exchangeRate.from] = exchangeRate.rate
                    }
                }.asVoid()
    }
    
    private func loadExchangeRate(fromCurrencyCode: String, toCurrencyCode: String) -> Promise<ExchangeRate> {
        return exchangeRatesCoordinator.show(from: fromCurrencyCode, to: toCurrencyCode)
    }
    
    private func transactionsAmount(type: TransactionableType) -> String? {
        guard let currency = defaultCurrency else { return nil }
        
        let transactions = filteredTransactionViewModels
            .filter { $0.sourceType == type || $0.destinationType == type }
        
        let amount = transactionsAmount(transactions: transactions)
        
        return amount.moneyCurrencyString(with: currency, shouldRound: false)
    }
    
    func transactionsAmount(transactions: [TransactionViewModel],
                                   amountForTransaction: ((TransactionViewModel) -> (cents: Int, currency: Currency))? = nil) -> NSDecimalNumber {
        guard let currency = defaultCurrency else { return 0.0 }
        
        return transactions
            .map { transaction -> NSDecimalNumber in
                
                if let amountForTransaction = amountForTransaction {
                    let amount = amountForTransaction(transaction)
                    let amountCents = amount.cents
                    let amountCurrency = amount.currency
                    
                    return amountCurrency.code == currency.code || amountCents == 0
                        ? NSDecimalNumber(integerLiteral: amountCents)
                        : convert(cents: amountCents, fromCurrency: amountCurrency, toCurrency: currency)
                } else {
                    
                    if transaction.currency.code == currency.code {
                        return NSDecimalNumber(integerLiteral: transaction.amountCents)
                    }
                    if transaction.convertedCurrency.code == currency.code {
                        return NSDecimalNumber(integerLiteral: transaction.convertedAmountCents)
                    }
                    
                    return convert(cents: transaction.calculatingAmountCents,
                                   fromCurrency: transaction.calculatingCurrency,
                                   toCurrency: currency)
                }                
            }
            .reduce(0, +)
    }
    
    private func convert(cents: Int, fromCurrency: Currency, toCurrency: Currency) -> NSDecimalNumber {
        
        guard let exchangeRate = exchangeRates[fromCurrency.code] else { return 0 }
        
        return currencyConverter.convert(cents: cents,
                                         fromCurrency: fromCurrency,
                                         toCurrency: toCurrency,
                                         exchangeRate: Double(exchangeRate),
                                         forward: true)
    }    
}
