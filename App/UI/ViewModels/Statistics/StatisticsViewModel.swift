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

enum StatisticsError : Error {
    case exchangeRateUnknown
}

class StatisticsViewModel {    
    private let transactionsViewModel: TransactionsViewModel
    private let filtersViewModel: FiltersViewModel
    let graphViewModel: GraphViewModel
    
    private let exportManager: ExportManagerProtocol
    
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
    
    init(transactionsViewModel: TransactionsViewModel,
         filtersViewModel: FiltersViewModel,
         exportManager: ExportManagerProtocol) {
        self.transactionsViewModel = transactionsViewModel
        self.filtersViewModel = filtersViewModel
        self.exportManager = exportManager
        graphViewModel = GraphViewModel(transactionsViewModel: self.transactionsViewModel)
        graphFiltersSection = GraphFiltersSection(viewModel: graphViewModel)
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
    
    func section(at index: Int) -> StatisticsViewSection? {
        return sections.item(at: index)
    }
    
    func transactionViewModel(at indexPath: IndexPath) -> TransactionViewModel? {
        guard let section = sections.item(at: indexPath.section) as? TransactionsSection else { return nil }
        return section.transactionViewModel(at: indexPath.row)
    }
    
    func exportTransactions() -> Promise<URL> {
        return exportManager.export(transactions: transactionsViewModel.filteredTransactionViewModels)
    }
    
    private func filterTransactions() {
        transactionsViewModel
            .filterTransactions(sourceOrDestinationFilters: filtersViewModel.sourceOrDestinationFilters,
                                       dateRangeFilter: filtersViewModel.dateRangeFilter)
    }
    
    private func updateGraphData() {
        if graphViewModel.graphPeriodScale == nil {
            graphViewModel.updateChartsData(with: transactionsViewModel.defaultPeriod)
        } else {
            graphViewModel.updateChartsData()
        }
        
    }
    
    private func updateTransactionsSections() {
        let groups = transactionsViewModel.filteredTransactionViewModels.groupByKey { $0.gotAt.dateAtStartOf(.day) }
        transactionsSections = groups
            .map { TransactionsSection(date: $0.key, transactionViewModels: $0.value) }
            .sorted(by: { $0.date > $1.date })
    }
    
    private func updateSections() {
        sections = []
        if filtersViewModel.isSingleSourceOrDestinationFilterSelectedAndEditable {
            sections.append(SourceOrDestinationFilterEditSection())
        }
        
        sections.append(GraphSection())
        
        updateGraphFiltersSection()
        if graphViewModel.hasData {
            sections.append(graphFiltersSection)
        }
        
        if isDataLoading {
            sections.append(TransactionsLoadingSection())
        } else if transactionsSections.count > 0 {
            sections.append(TransactionsHeaderSection())
            sections.append(contentsOf: transactionsSections)
        }
    }
}

// History Transactions
extension StatisticsViewModel {
    var hasIncomeTransactions: Bool {
        return transactionsViewModel.hasIncomeTransactions
    }
    
    var hasExpenseTransactions: Bool {
        return transactionsViewModel.hasExpenseTransactions
    }
    
    var filteredIncomesAmount: String? {
        return transactionsViewModel.filteredIncomesAmount
    }
    
    var filteredExpensesAmount: String? {
        return transactionsViewModel.filteredExpensesAmount
    }
    
    func loadData() -> Promise<Void> {
        setDataLoading()
        return  firstly {
                    transactionsViewModel.loadData()
                }.ensure {
                    self.isDataLoading = false
                    self.updatePresentationData()                    
                }
    }
    
    func reloadFilterAndData() -> Promise<Void> {
        setDataLoading()
        return  firstly {
                    when(fulfilled: filtersViewModel.reloadFilter(), transactionsViewModel.loadData())
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
    
    func removeTransaction(transactionViewModel: TransactionViewModel) -> Promise<Void> {
        setDataLoading()
        return transactionsViewModel.removeTransaction(transactionViewModel: transactionViewModel)
    }
}

// Filters
extension StatisticsViewModel {
    var dateRangeFilter: DateRangeTransactionFilter? {
        return filtersViewModel.dateRangeFilter
    }
    
    var sourceOrDestinationFilters: [SourceOrDestinationTransactionFilter] {
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
    
    var isSingleSourceOrDestinationFilterSelectedAndEditable: Bool {
        return filtersViewModel.isSingleSourceOrDestinationFilterSelectedAndEditable
    }
    
    var singleSourceOrDestinationFilter: SourceOrDestinationTransactionFilter? {
        return filtersViewModel.singleSourceOrDestinationFilter
    }
    
    func set(sourceOrDestinationFilter: SourceOrDestinationTransactionFilter?) {
        guard let sourceOrDestinationFilter = sourceOrDestinationFilter else { return }
        func graphType(by filterType: TransactionableType) -> GraphType {
            switch sourceOrDestinationFilter.type {
            case .incomeSource:
                return .income
            case .expenseSource:
                return .cashFlow
            case .expenseCategory:
                return .expenses
            default:
                return .expenses
            }
        }        
        set(graphType: graphType(by: sourceOrDestinationFilter.type))
        set(sourceOrDestinationFilters: [sourceOrDestinationFilter])
    }
    
    func set(sourceOrDestinationFilters: [SourceOrDestinationTransactionFilter]) {
        filtersViewModel.set(sourceOrDestinationFilters: sourceOrDestinationFilters)
        updatePresentationData()
    }
    
    func set(dateRangeFilter: DateRangeTransactionFilter?) {
        filtersViewModel.set(dateRangeFilter: dateRangeFilter)
        updatePresentationData()
    }
    
    func set(dateRangeFilter: DateRangeTransactionFilter?, sourceOrDestinationFilters: [SourceOrDestinationTransactionFilter]) {
        filtersViewModel.set(dateRangeFilter: dateRangeFilter)
        filtersViewModel.set(sourceOrDestinationFilters: sourceOrDestinationFilters)
        updatePresentationData()
    }
    
    func removeDateRangeFilter() {
        set(dateRangeFilter: nil)
    }
    
    func remove(sourceOrDestinationFilter: SourceOrDestinationTransactionFilter) {
        let filters = filtersViewModel.sourceOrDestinationFilters.filter { $0.id != sourceOrDestinationFilter.id }
        set(sourceOrDestinationFilters: filters)
    }
    
    func sourceOrDestinationFilter(at indexPath: IndexPath) -> SourceOrDestinationTransactionFilter? {
        return filtersViewModel.sourceOrDestinationFilter(at: indexPath)
    }
    
    func singleSourceOrDestinationFilterEqualsTo(filter: GraphTransactionFilter) -> Bool {
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
