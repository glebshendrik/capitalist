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
    let graphViewModel: GraphViewModel
    
    public private(set) var isDataLoading: Bool = false
    
    private var sections: [StatisticsViewSection] = []
    private var historyTransactionsSections: [HistoryTransactionsSection] = []    
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
    
    init(historyTransactionsViewModel: HistoryTransactionsViewModel,
         filtersViewModel: FiltersViewModel) {
        self.historyTransactionsViewModel = historyTransactionsViewModel
        self.filtersViewModel = filtersViewModel
        graphViewModel = GraphViewModel(historyTransactionsViewModel: self.historyTransactionsViewModel)
        graphFiltersSection = GraphFiltersSection(viewModel: graphViewModel)
    }
    
    func setDataLoading() {
        isDataLoading = true
        updateSections()
    }
    
    func updatePresentationData() {
        filterHistoryTransactions()
        updateGraphData()
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
    
    private func updateGraphData() {
        graphViewModel.updateChartsData()
    }
    
    private func updateHistoryTransactionsSections() {
        let groups = historyTransactionsViewModel.filteredHistoryTransactionViewModels.groupByKey { $0.gotAt.dateAtStartOf(.day) }
        historyTransactionsSections = groups
            .map { HistoryTransactionsSection(date: $0.key, historyTransactionViewModels: $0.value) }
            .sorted(by: { $0.date > $1.date })
    }
    
    private func updateSections() {
        sections = []
        if filtersViewModel.isSingleSourceOrDestinationFilterSelected {
            sections.append(SourceOrDestinationFilterEditSection())
        }
        
        sections.append(GraphSection())
        
        updateGraphFiltersSection()
        sections.append(graphFiltersSection)
        
        if isDataLoading {
            sections.append(HistoryTransactionsLoadingSection())
        } else if historyTransactionsSections.count > 0 {
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
        setDataLoading()
        return  firstly {
                    historyTransactionsViewModel.loadData()
                }.ensure {
                    self.isDataLoading = false
                    self.updatePresentationData()                    
                }
    }
    
    func reloadFilterAndData() -> Promise<Void> {
        setDataLoading()
        return  firstly {
                    when(fulfilled: filtersViewModel.reloadFilter(), historyTransactionsViewModel.loadData())
                }.ensure {
                    self.isDataLoading = false
                    self.updatePresentationData()
                }
    }
    
    func reloadFilter() -> Promise<Void> {
        return  firstly {
                    filtersViewModel.reloadFilter()
                }.ensure {
                    self.isDataLoading = false
                    self.updatePresentationData()
                }
    }
}

// Filters
extension StatisticsViewModel {
    var dateRangeFilter: DateRangeHistoryTransactionFilter? {
        return filtersViewModel.dateRangeFilter
    }
    
    var sourceOrDestinationFilters: [SourceOrDestinationHistoryTransactionFilter] {
        return filtersViewModel.sourceOrDestinationFilters
    }
    
    var numberOfSourceOrDestinationFilters: Int {
        return filtersViewModel.numberOfSourceOrDestinationFilters
    }
    
    var editFilterTitle: String? {
        return filtersViewModel.editFilterTitle
    }
    
    var hasSourceOrDestinationFilters: Bool {
        return numberOfSourceOrDestinationFilters > 0
    }
    
    var isSingleSourceOrDestinationFilterSelected: Bool {
        return filtersViewModel.isSingleSourceOrDestinationFilterSelected
    }
    
    var singleSourceOrDestinationFilter: SourceOrDestinationHistoryTransactionFilter? {
        return filtersViewModel.singleSourceOrDestinationFilter
    }
    
    func set(sourceOrDestinationFilter: SourceOrDestinationHistoryTransactionFilter) {
        func graphType(by filterType: HistoryTransactionSourceOrDestinationType) -> GraphType {
            switch sourceOrDestinationFilter.type {
            case .incomeSource:
                return .incomePie
            case .expenseSource:
                return .cashFlow
            case .expenseCategory:
                return .expensesPie
            }
        }        
        set(graphType: graphType(by: sourceOrDestinationFilter.type))
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
    
    func set(dateRangeFilter: DateRangeHistoryTransactionFilter?, sourceOrDestinationFilters: [SourceOrDestinationHistoryTransactionFilter]) {
        filtersViewModel.set(dateRangeFilter: dateRangeFilter)
        filtersViewModel.set(sourceOrDestinationFilters: sourceOrDestinationFilters)
        updatePresentationData()
    }
    
    func removeDateRangeFilter() {
        set(dateRangeFilter: nil)
    }
    
    func remove(sourceOrDestinationFilter: SourceOrDestinationHistoryTransactionFilter) {
        let filters = filtersViewModel.sourceOrDestinationFilters.filter { $0.id != sourceOrDestinationFilter.id }
        set(sourceOrDestinationFilters: filters)
    }
    
    func sourceOrDestinationFilter(at indexPath: IndexPath) -> SourceOrDestinationHistoryTransactionFilter? {
        return filtersViewModel.sourceOrDestinationFilter(at: indexPath)
    }
    
    func singleSourceOrDestinationFilterEqualsTo(filter: GraphHistoryTransactionFilter) -> Bool {
        return singleSourceOrDestinationFilter?.id == filter.id && singleSourceOrDestinationFilter?.type == filter.type
    }
}

// Graph
extension StatisticsViewModel {
    var aggregationTypes: [AggregationType] {
        return graphViewModel.aggregationTypes
    }
    
    var areGraphFiltersInteractable: Bool {
        return graphViewModel.areGraphFiltersInteractable
    }
    
    func set(graphType: GraphType) {
        graphViewModel.graphType = graphType
    }
    
    func set(graphScale: GraphPeriodScale) {
        graphViewModel.graphPeriodScale = graphScale
    }
    
    func set(aggregationType: AggregationType) {
        graphViewModel.aggregationType = aggregationType
    }
    
    func switchLinePieChart() {
        graphViewModel.switchLinePieChart()
    }
    
    func toggleGraphFilters() {
        graphViewModel.toggleFilters()
    }
    
    func updateGraphFiltersSection() {
        graphFiltersSection.updateRows()
    }
    
    func graphFilterViewModel(at index: Int) -> GraphHistoryTransactionFilter? {
        return graphViewModel.graphFilterViewModel(at: index)
    }
    
    func canFilterTransactions(with filter: GraphHistoryTransactionFilter) -> Bool {
        return graphViewModel.canFilterTransactions(with: filter)
    }
    
    func handleIncomeAndExpensesFilterTap(with filter: GraphHistoryTransactionFilter) {
        graphViewModel.handleIncomeAndExpensesFilterTap(with: filter)
    }
}
