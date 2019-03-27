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
    
    private var defaultCurrency: Currency? = nil
    private var allCurrencyCodes: [String] = []
    private var exchangeRates: [String : Float] = [String : Float]()
    
    private var allHistoryTransactionViewModels: [HistoryTransactionViewModel] = [] {
        didSet {
            allCurrencyCodes = allHistoryTransactionViewModels.map { $0.currency.code }.withoutDuplicates()
        }
    }
    
    public private(set) var filteredHistoryTransactionViewModels: [HistoryTransactionViewModel] = []
    
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
         accountCoordinator: AccountCoordinatorProtocol) {
        self.historyTransactionsCoordinator = historyTransactionsCoordinator
        self.exchangeRatesCoordinator = exchangeRatesCoordinator
        self.accountCoordinator = accountCoordinator
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
        
        return filteredHistoryTransactionViewModels
            .filter { $0.sourceType == type || $0.destinationType == type }
            .map { $0.currency.code == currency.code
                ? $0.amountCents
                : convert(amountCents: $0.amountCents, fromCurrency: $0.currency) }
            .sum()
            .moneyCurrencyString(with: currency)
    }
    
    private func convert(amountCents: Int, fromCurrency: Currency) -> Int {
        guard let exchangeRate = exchangeRates[fromCurrency.code] else { return 0 }
        
        let convertedAmountCents = Int((Float(amountCents) * exchangeRate).rounded())
        
        return convertedAmountCents
    }
}
