//
//  StatisticsViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 22/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftDate
import SwifterSwift

enum StatisticsError : Error {
    case exchangeRateUnknown
}

class StatisticsViewModel {    
    private let transactionsViewModel: TransactionsViewModel
    private let periodsViewModel: PeriodsViewModel
    private let filtersViewModel: FiltersViewModel
    private let accountCoordinator: AccountCoordinatorProtocol
    
    let graphViewModel: GraphViewModel
    
    public private(set) var isDataLoading: Bool = false
    
    private var sections: [StatisticsViewSection] = []
    private var transactionsSections: [TransactionsSection] = []    
    private let graphFiltersSection: GraphFiltersSection
    
    var numberOfSections: Int {
        return sections.count
    }
    
    var graphFiltersSectionIndex: Int? {
        return sections.firstIndex { $0.type == .graphFilters }
    }
    
    var graphSectionIndex: Int? {
        return sections.firstIndex { $0.type == .graph }
    }
    
    var canShowFilters: Bool {
        return accountCoordinator.premiumFeaturesAvailable
    }
    
    init(transactionsViewModel: TransactionsViewModel,
         filtersViewModel: FiltersViewModel,
         periodsViewModel: PeriodsViewModel,
         accountCoordinator: AccountCoordinatorProtocol) {
        self.transactionsViewModel = transactionsViewModel
        self.periodsViewModel = periodsViewModel
        self.filtersViewModel = filtersViewModel
        self.accountCoordinator = accountCoordinator
        graphViewModel = GraphViewModel(transactionsViewModel: self.transactionsViewModel, periodsViewModel: self.periodsViewModel)
        graphFiltersSection = GraphFiltersSection(viewModel: graphViewModel)
    }
    
    func section(at index: Int) -> StatisticsViewSection? {
        return sections[safe: index]
    }
    
    func transactionViewModel(at indexPath: IndexPath) -> TransactionViewModel? {        
        guard let section = sections[safe: indexPath.section] as? TransactionsSection else { return nil }
        return section.transactionViewModel(at: indexPath.row)
    }
    
    func setDataLoading() {
        isDataLoading = true
        updateSections()
    }
    
    func updatePresentationData() {
        filterTransactions()
        updateGraphData()
        updateTransactionsSections()
        updateSections()
    }
    
    func updatePeriods(dateRangeFilter: DateRangeTransactionFilter? = nil) {
        let filter = dateRangeFilter ?? DateRangeTransactionFilter(datePeriod: .month)
        graphViewModel.collectionContentOffset = nil
        periodsViewModel.set(dateRangeFilter: filter,
                             beginning: oldestTransactionDate,
                             ending: newestTransactionDate)
    }
    
    private func filterTransactions() {
        transactionsViewModel
            .filterTransactions(filters: filtersViewModel.transactionableFilters,
                                graphType: graphViewModel.graphType)
    }
    
    private func updateGraphData() {
        graphViewModel.updateCurrentGraph()
    }
    
    private func updateTransactionsSections() {
        let groups = transactionsViewModel.filteredTransactionViewModels.groupByKey { $0.gotAtStartOfDay }
        
        transactionsSections = groups
            .map { TransactionsSection(date: $0.key, transactionViewModels: $0.value, amount: amountForSection(transactions: $0.value)) }
            .sorted(by: { $0.date > $1.date })
    }
    
    private func amountForSection(transactions: [TransactionViewModel]) -> String? {
        
        var incomes = transactions.filter { $0.type == .income || $0.hasPositiveProfit }
        
        var expenses = transactions.filter { $0.type == .expense || $0.hasNegativeProfit }
        
        func amountCents() -> NSDecimalNumber {
            switch graphViewModel.graphType {
            case .all:
                return transactionsViewModel.transactionsAmount(transactions: incomes).subtracting(transactionsViewModel.transactionsAmount(transactions: expenses))
            case .incomes:
                return transactionsViewModel.transactionsAmount(transactions: incomes)
            case .expenses:
                return transactionsViewModel.transactionsAmount(transactions: expenses)
            }
        }
        
        let cents = amountCents()
        
        guard !cents.isEqual(0) else { return nil }
        
        guard let amount = cents.moneyCurrencyString(with: transactionsViewModel.defaultCurrency, shouldRound: false) else { return nil }
        
        switch graphViewModel.graphType {
        case .all:
            if cents.intValue > 0 {
                return "+\(amount)"
            }
            return amount
        case .incomes:
            return "+\(amount)"
        case .expenses:
            return "–\(amount)"
        }
    }
    
    private func updateSections() {
        sections = []
        
        sections.append(GraphSection())
        
        if isDataLoading {
            sections.append(TransactionsLoadingSection())
        }
        
        if graphViewModel.hasData {
            sections.append(graphFiltersSection)
        }
        
        if !isDataLoading && transactionsSections.count > 0 {
            sections.append(TransactionsHeaderSection())
            sections.append(contentsOf: transactionsSections)
        }
    }
}

// Transactions
extension StatisticsViewModel {
    var oldestTransactionDate: Date {
        return transactionsViewModel.oldestTransactionDate
    }
    
    var newestTransactionDate: Date {
        return Date()
    }
    
    func loadData() -> Promise<Void> {
        clearTransactions()
        setDataLoading()
        let previousOldestTransactionDate = oldestTransactionDate
        return  firstly {
                    transactionsViewModel.loadData(dateRangeFilter: periodsViewModel.currentDateRangeFilter)
                }.ensure {
                    self.isDataLoading = false
                    if self.oldestTransactionDate != previousOldestTransactionDate {
                        self.updatePeriods(dateRangeFilter: self.periodsViewModel.currentDateRangeFilter)
                    }
                    self.updatePresentationData()
                }
    }
    
    func clearTransactions() {
        transactionsViewModel.clearTransactions()
        updatePresentationData()
    }
    
    func loadTransactions() -> Promise<Void> {
            setDataLoading()
            return  firstly {
                        transactionsViewModel.loadTransactions(dateRangeFilter: periodsViewModel.currentDateRangeFilter)
                    }.ensure {
                        self.isDataLoading = false
                        self.updatePresentationData()
                    }
        }
            
    func removeTransaction(transactionViewModel: TransactionViewModel) -> Promise<Void> {
        setDataLoading()
        return transactionsViewModel.removeTransaction(transactionViewModel: transactionViewModel)
    }
    
    func duplicateTransaction(transactionViewModel: TransactionViewModel) -> Promise<Void> {
        setDataLoading()
        return transactionsViewModel.duplicateTransaction(transactionViewModel: transactionViewModel)
    }
}

// Filters
extension StatisticsViewModel {
    var dateRangeFilter: DateRangeTransactionFilter? {
        return periodsViewModel.currentDateRangeFilter
    }
    
    var transactionableFilters: [TransactionableFilter] {
        return filtersViewModel.transactionableFilters
    }
    
    var numberOfTransactionableFilters: Int {
        return filtersViewModel.numberOfTransactionableFilters
    }
        
    var hasTransactionableFilters: Bool {
        return numberOfTransactionableFilters > 0
    }
    
    func transactionableFilter(at indexPath: IndexPath) -> TransactionableFilter? {
        return filtersViewModel.transactionableFilter(at: indexPath)
    }
    
    func set(filter: TransactionableFilter?) {
        guard let filter = filter else { return }
        func graphType(by filterType: TransactionableType) -> GraphType {
            switch filter.type {
            case .incomeSource:
                return .incomes
            case .expenseCategory:
                return .expenses
            default:
                return .all
            }
        }
        if let compoundGraphTransactionFilter = filter as? CompoundGraphTransactionFilter {
            set(filters: compoundGraphTransactionFilter.filters)
        }
        else {
//            set(graphType: graphType(by: filter.type))
            set(filters: [filter])
        }
    }
    
    func set(filters: [TransactionableFilter]) {
        filtersViewModel.set(transactionableFilters: filters)
        updatePresentationData()
    }
}

// Graph
extension StatisticsViewModel {
    func set(graphType: GraphType) {
        graphViewModel.graphType = graphType
    }
        
    func graphFilterViewModel(at index: Int) -> GraphTransactionFilter? {
        return graphViewModel.graphFilterViewModel(at: index)
    }
    
    func canFilterTransactions(with filter: GraphTransactionFilter) -> Bool {
        return graphViewModel.canFilterTransactions(with: filter)
    }
    
    func handleIncomeAndExpensesFilterTap(with filter: GraphTransactionFilter) {
        graphViewModel.handleIncomeAndExpensesFilterTap(with: filter)
    }
}
