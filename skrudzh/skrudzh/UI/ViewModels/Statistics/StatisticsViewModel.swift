//
//  StatisticsViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 22/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftDate

enum StatisticsError : Error {
    case exchangeRateUnknown
}

class StatisticsViewModel {    
    private let historyTransactionsViewModel: HistoryTransactionsViewModel
    private let filtersViewModel: FiltersViewModel
    
    public private(set) var isDataLoaded: Bool = false
    
    private var sections: [StatisticsViewSection] = []
    private var historyTransactionsSections: [HistoryTransactionsSection] = []
    
    var numberOfSections: Int {
        return sections.count
    }
    
    init(historyTransactionsViewModel: HistoryTransactionsViewModel,
         filtersViewModel: FiltersViewModel) {
        self.historyTransactionsViewModel = historyTransactionsViewModel
        self.filtersViewModel = filtersViewModel
    }
    
    func updatePresentationData() {
        filterHistoryTransactions()
        updateHistoryTransactionsSections()
        updateSections()
    }
    
    func section(at index: Int) -> StatisticsViewSection? {
        return sections.item(at: index)
    }
    
    func historyTransactionViewModel(at indexPath: IndexPath) -> HistoryTransactionViewModel? {
        guard let section = sections.item(at: indexPath.section) as? HistoryTransactionsSection else { return nil }
        return section.historyTransactionViewModel(at: indexPath.row)
    }
    
    private func filterHistoryTransactions() {
        historyTransactionsViewModel
            .filterHistoryTransactions(sourceOrDestinationFilters: filtersViewModel.sourceOrDestinationFilters,
                                       dateRangeFilter: filtersViewModel.dateRangeFilter)
    }
    
    private func updateHistoryTransactionsSections() {
        let groups = historyTransactionsViewModel.filteredHistoryTransactionViewModels.groupByKey { $0.gotAt.dateAtStartOf(.day) }
        historyTransactionsSections = groups.map { HistoryTransactionsSection(date: $0.key, historyTransactionViewModels: $0.value) }
    }
    
    private func updateSections() {
        sections = []
        if filtersViewModel.isSingleSourceOrDestinationFilterSelected {
            sections.append(SourceOrDestinationFilterEditSection())
        }
        sections.append(GraphSection())
        if !isDataLoaded {
            sections.append(HistoryTransactionsLoadingSection())
        }
        if historyTransactionsSections.count > 0 {
            sections.append(HistoryTransactionsHeaderSection())
            sections.append(contentsOf: historyTransactionsSections)
        }
    }
}

// History Transactions
extension StatisticsViewModel {
    var hasIncomeTransactions: Bool {
        return historyTransactionsViewModel.hasIncomeTransactions
    }
    
    var hasExpenseTransactions: Bool {
        return historyTransactionsViewModel.hasExpenseTransactions
    }
    
    var filteredIncomesAmount: String? {
        return historyTransactionsViewModel.filteredIncomesAmount
    }
    
    var filteredExpensesAmount: String? {
        return historyTransactionsViewModel.filteredExpensesAmount
    }
    
    func loadData() -> Promise<Void> {
        return  firstly {
                    historyTransactionsViewModel.loadData()
                }.ensure {
                    self.isDataLoaded = true
                    self.updatePresentationData()                    
                }
    }
}

// Filters
extension StatisticsViewModel {
    var dateRangeFilter: DateRangeHistoryTransactionFilter? {
        return filtersViewModel.dateRangeFilter
    }
    
    var numberOfSourceOrDestinationFilters: Int {
        return filtersViewModel.numberOfSourceOrDestinationFilters
    }
    
    var isSingleSourceOrDestinationFilterSelected: Bool {
        return filtersViewModel.isSingleSourceOrDestinationFilterSelected
    }
    
    var singleSourceOrDestinationFilter: SourceOrDestinationHistoryTransactionFilter? {
        return filtersViewModel.singleSourceOrDestinationFilter
    }
    
    func set(sourceOrDestinationFilter: SourceOrDestinationHistoryTransactionFilter) {
        set(sourceOrDestinationFilters: [sourceOrDestinationFilter])
    }
    
    func set(sourceOrDestinationFilters: [SourceOrDestinationHistoryTransactionFilter]) {
        filtersViewModel.set(sourceOrDestinationFilters: sourceOrDestinationFilters)
        updatePresentationData()
    }
    
    func set(dateRangeFilter: DateRangeHistoryTransactionFilter?) {
        filtersViewModel.set(dateRangeFilter: dateRangeFilter)
        updatePresentationData()
    }
    
    func sourceOrDestinationFilter(at indexPath: IndexPath) -> SourceOrDestinationHistoryTransactionFilter? {
        return filtersViewModel.sourceOrDestinationFilter(at: indexPath)
    }
}
