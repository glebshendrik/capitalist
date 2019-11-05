//
//  FiltersSelectionViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 02/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class FiltersSelectionViewModel {
    private let incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol
    private let expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol
    private let expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol
    
    public private(set) var sourceOrDestinationFilters: [SourceOrDestinationTransactionFilter] = [] {
        didSet {
            calculatePassedFiltersHash()
        }
    }
    private var passedFiltersHash: [TransactionableType : [Int : SourceOrDestinationTransactionFilter]] = [:]
    
    public private(set) var dateRangeFilter: DateRangeTransactionFilter? = nil {
        didSet {
            fromDate = dateRangeFilter?.fromDate
            toDate = dateRangeFilter?.toDate
        }
    }
    
    var fromDate: Date? {
        didSet {
            toDateMinDate = fromDate
        }
    }
    
    var toDate: Date? {
        didSet {
            fromDateMaxDate = toDate
        }
    }
    
    var fromDateMaxDate: Date?
    var toDateMinDate: Date?
        
    private var incomeSourceFiltersSection: IncomeSourceFiltersSection? = nil
    private var expenseSourceFiltersSection: ExpenseSourceFiltersSection? = nil
    private var joyExpenseCategoryFiltersSection: JoyExpenseCategoryFiltersSection? = nil
    private var riskExpenseCategoryFiltersSection: RiskExpenseCategoryFiltersSection? = nil
    private var safeExpenseCategoryFiltersSection: SafeExpenseCategoryFiltersSection? = nil
    
    private var sections: [FiltersSelectionViewSection] = []
    
    var selectedFilters: [SourceOrDestinationTransactionFilter] {
        
        let filtersSections: [SourceOrDestinationTransactionFiltersSection?] =
            [incomeSourceFiltersSection,
             expenseSourceFiltersSection,
             joyExpenseCategoryFiltersSection,
             riskExpenseCategoryFiltersSection,
             safeExpenseCategoryFiltersSection]
        
        return filtersSections.compactMap { $0 }.flatMap { $0.selectedFilters }
    }
    
    var selectedDateRangeFilter: DateRangeTransactionFilter? {
        if fromDate == nil && toDate == nil {
            return nil
        }
        return DateRangeTransactionFilter(fromDate: fromDate, toDate: toDate)
    }
    
    var numberOfSections: Int {
        return sections.count
    }
    
    init(incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol,
         expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol,
         expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol) {
        self.incomeSourcesCoordinator = incomeSourcesCoordinator
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
        self.expenseCategoriesCoordinator = expenseCategoriesCoordinator
    }
    
    func section(at index: Int) -> FiltersSelectionViewSection? {
        return sections.item(at: index)
    }
    
    func numberOfRowsInSection(index: Int) -> Int {
        guard let section = section(at: index) else { return 0 }
        return section.numberOfRows
    }
    
    func titleForSection(index: Int) -> String? {
        return section(at: index)?.title
    }
    
    func filterViewModel(at indexPath: IndexPath) -> SelectableSourceOrDestinationTransactionFilter? {
        guard let section = section(at: indexPath.section) as? SourceOrDestinationTransactionFiltersSection else { return nil }
        return section.filterViewModel(at: indexPath.row)
    }
    
    func set(dateRangeFilter: DateRangeTransactionFilter?, sourceOrDestinationFilters: [SourceOrDestinationTransactionFilter]) {
        self.dateRangeFilter = dateRangeFilter
        self.sourceOrDestinationFilters = sourceOrDestinationFilters
    }
    
    func loadFilters() -> Promise<Void> {
        return  firstly {
                    when(fulfilled: loadIncomeSourceFilters(),
                         loadExpenseSourceFilters(),
                         loadExpenseCategoryFilters(basketType: .joy),
                         loadExpenseCategoryFilters(basketType: .risk),
                         loadExpenseCategoryFilters(basketType: .safe))
                }.ensure {
                    self.setupSections()
                }
    }
    
    private func setupSections() {
        let collection: [FiltersSelectionViewSection?] = [DateRangeFilterSection(),
                                                          incomeSourceFiltersSection,
                                                          expenseSourceFiltersSection,
                                                          joyExpenseCategoryFiltersSection,
                                                          riskExpenseCategoryFiltersSection,
                                                          safeExpenseCategoryFiltersSection]
        sections = collection.compactMap { $0 }
    }
    
    private func loadIncomeSourceFilters() -> Promise<Void> {
        return  firstly {
                    incomeSourcesCoordinator.index(noBorrows: false)
                }.get { incomeSources in
                    let incomeSourceFilters: [IncomeSourceTransactionFilter] = incomeSources.map { incomeSource in
                        
                        let incomeSourceViewModel = IncomeSourceViewModel(incomeSource: incomeSource)
                        let isSelected = self.passedFiltersHash[.incomeSource]?[incomeSource.id] != nil
                        
                        return IncomeSourceTransactionFilter(incomeSourceViewModel: incomeSourceViewModel,
                                                                    isSelected: isSelected)
                    }
                    self.incomeSourceFiltersSection = IncomeSourceFiltersSection(incomeSourceFilters: incomeSourceFilters)
                }.asVoid()
    }
    
    private func loadExpenseSourceFilters() -> Promise<Void> {
        return  firstly {
                    expenseSourcesCoordinator.index(currency: nil)
                }.get { expenseSources in
                    let expenseSourceFilters: [ExpenseSourceTransactionFilter] = expenseSources.map { expenseSource in
                        
                        let expenseSourceViewModel = ExpenseSourceViewModel(expenseSource: expenseSource)
                        let isSelected = self.passedFiltersHash[.expenseSource]?[expenseSource.id] != nil
                        
                        return ExpenseSourceTransactionFilter(expenseSourceViewModel: expenseSourceViewModel,
                                                                    isSelected: isSelected)
                    }
                    self.expenseSourceFiltersSection = ExpenseSourceFiltersSection(expenseSourceFilters: expenseSourceFilters)
                }.asVoid()
    }
    
    private func loadExpenseCategoryFilters(basketType: BasketType) -> Promise<Void> {
        return  firstly {
                    expenseCategoriesCoordinator.index(for: basketType, noBorrows: false)
                }.get { expenseCategories in
                    let expenseCategoryFilters: [ExpenseCategoryTransactionFilter] = expenseCategories.map { expenseCategory in
                        
                        let expenseCategoryViewModel = ExpenseCategoryViewModel(expenseCategory: expenseCategory)
                        let isSelected = self.passedFiltersHash[.expenseCategory]?[expenseCategory.id] != nil
                        
                        return ExpenseCategoryTransactionFilter(expenseCategoryViewModel: expenseCategoryViewModel,
                                                                    isSelected: isSelected)
                    }
                    self.set(expenseCategoryFilters: expenseCategoryFilters, by: basketType)
                }.asVoid()
    }

    private func set(expenseCategoryFilters: [ExpenseCategoryTransactionFilter], by basketType: BasketType) {
        switch basketType {
        case .joy:
            joyExpenseCategoryFiltersSection = JoyExpenseCategoryFiltersSection(joyExpenseCategoryFilters: expenseCategoryFilters)
        case .risk:
            riskExpenseCategoryFiltersSection = RiskExpenseCategoryFiltersSection(riskExpenseCategoryFilters: expenseCategoryFilters)
        case .safe:
            safeExpenseCategoryFiltersSection = SafeExpenseCategoryFiltersSection(safeExpenseCategoryFilters: expenseCategoryFilters)
        }
    }
    
    private func calculatePassedFiltersHash() {
        passedFiltersHash = [TransactionableType : [Int : SourceOrDestinationTransactionFilter]]()
        
        for filter in sourceOrDestinationFilters {
            if passedFiltersHash[filter.type] == nil {
                passedFiltersHash[filter.type] = [Int : SourceOrDestinationTransactionFilter]()
            }
            passedFiltersHash[filter.type]?[filter.id] = filter
        }
    }
}
