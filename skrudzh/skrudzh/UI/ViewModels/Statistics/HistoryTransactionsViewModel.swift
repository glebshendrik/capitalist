//
//  HistoryTransactionsViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 27/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit
import SwifterSwift

class HistoryTransactionsViewModel {
    private let historyTransactionsCoordinator: HistoryTransactionsCoordinatorProtocol
    private let exchangeRatesCoordinator: ExchangeRatesCoordinatorProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    private let currencyConverter: CurrencyConverterProtocol
    
    private var allCurrencyCodes: [String] = []
    var defaultCurrency: Currency? = nil
    var defaultPeriod: AccountingPeriod? = nil
    private var exchangeRates: [String : Float] = [String : Float]()
    
    public private(set) var filteredHistoryTransactionViewModels: [HistoryTransactionViewModel] = []
    
    private var allHistoryTransactionViewModels: [HistoryTransactionViewModel] = [] {
        didSet {
            allCurrencyCodes = allHistoryTransactionViewModels.map { $0.currency.code }.withoutDuplicates()
        }
    }
    
    var hasIncomeTransactions: Bool {
        return filteredHistoryTransactionViewModels.any { $0.sourceType == .incomeSource }
    }
    
    var hasExpenseTransactions: Bool {
        return filteredHistoryTransactionViewModels.any { $0.destinationType == .expenseCategory }
    }
    
    var filteredIncomesAmount: String? {
        return historyTransactionsAmount(type: .incomeSource)
    }
    
    var filteredExpensesAmount: String? {
        return historyTransactionsAmount(type: .expenseCategory)
    }
    
    init(historyTransactionsCoordinator: HistoryTransactionsCoordinatorProtocol,
         exchangeRatesCoordinator: ExchangeRatesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         currencyConverter: CurrencyConverterProtocol) {
        self.historyTransactionsCoordinator = historyTransactionsCoordinator
        self.exchangeRatesCoordinator = exchangeRatesCoordinator
        self.accountCoordinator = accountCoordinator
        self.currencyConverter = currencyConverter
    }
    
    func loadData() -> Promise<Void> {
        return  firstly {
                    when(fulfilled: loadDefaultCurrency(), loadHistoryTransactions())
                }.then {
                    self.loadExchangeRates()
                }
    }
    
    func filterHistoryTransactions(sourceOrDestinationFilters: [SourceOrDestinationHistoryTransactionFilter],
                                   dateRangeFilter: DateRangeHistoryTransactionFilter?) {
        
        var historyTransactionViewModels = allHistoryTransactionViewModels
        
        if sourceOrDestinationFilters.count > 0 {
            
            var filtersHash = [HistoryTransactionSourceOrDestinationType : [Int : SourceOrDestinationHistoryTransactionFilter]]()
            
            for filter in sourceOrDestinationFilters {
                if filtersHash[filter.type] == nil {
                    filtersHash[filter.type] = [Int : SourceOrDestinationHistoryTransactionFilter]()
                }
                filtersHash[filter.type]?[filter.id] = filter
            }
            
            historyTransactionViewModels = historyTransactionViewModels.filter {
                (filtersHash[$0.sourceType]?[$0.sourceId] ??
                    filtersHash[$0.destinationType]?[$0.destinationId]) != nil
            }
        }
        
        if let fromDate = dateRangeFilter?.fromDate {
            historyTransactionViewModels = historyTransactionViewModels.filter {
                $0.gotAt >= fromDate
            }
        }
        
        if let toDate = dateRangeFilter?.toDate {
            historyTransactionViewModels = historyTransactionViewModels.filter {
                $0.gotAt <= toDate
            }
        }
        
        filteredHistoryTransactionViewModels = historyTransactionViewModels
    }
    
    private func loadDefaultCurrency() -> Promise<Void> {
        return  firstly {
                    accountCoordinator.loadCurrentUser()
                }.get { user in
                    self.defaultCurrency = user.currency
                    self.defaultPeriod = user.defaultPeriod
                }.asVoid()
    }
    
    private func loadHistoryTransactions() -> Promise<Void> {
        return  firstly {
                    historyTransactionsCoordinator.index()
                }.get { historyTransactions in
                    self.allHistoryTransactionViewModels = historyTransactions.map { HistoryTransactionViewModel(historyTransaction: $0) }
                }.asVoid()
    }
    
    private func loadExchangeRates() -> Promise<Void> {
        guard let defaultCurrencyCode = defaultCurrency?.code else {
            return Promise(error: StatisticsError.exchangeRateUnknown)
        }
        let fromCurrencyCodes = allCurrencyCodes.filter { $0 != defaultCurrencyCode }
        return  firstly {
                    when(fulfilled: fromCurrencyCodes.map { loadExchangeRate(fromCurrencyCode: $0,
                                                                     toCurrencyCode: defaultCurrencyCode)} )
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
    
    private func historyTransactionsAmount(type: HistoryTransactionSourceOrDestinationType) -> String? {
        guard let currency = defaultCurrency else { return nil }
        
        let transactions = filteredHistoryTransactionViewModels
            .filter { $0.sourceType == type || $0.destinationType == type }
        
        let amount = historyTransactionsAmount(transactions: transactions)
        
        return amount.moneyCurrencyString(with: currency, shouldRound: false)
    }
    
    func historyTransactionsAmount(transactions: [HistoryTransactionViewModel],
                                   amountCentsForTransaction: ((HistoryTransactionViewModel) -> Int) = { $0.amountCents }) -> NSDecimalNumber {
        guard let currency = defaultCurrency else { return 0.0 }
        
        return transactions
            .map { $0.currency.code == currency.code
                ? NSDecimalNumber(integerLiteral: amountCentsForTransaction($0))
                : convert(cents: amountCentsForTransaction($0), fromCurrency: $0.currency, toCurrency: currency) }
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
