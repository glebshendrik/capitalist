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
    private let activesCoordinator: ActivesCoordinatorProtocol
    
    public private(set) var transactionableFilters: [TransactionableFilter] = [] {
        didSet {
            calculatePassedFiltersHash()
        }
    }
    
    private var passedFiltersHash: [TransactionableType : [Int : TransactionableFilter]] = [:]
    
    private var incomeSourceFiltersSection: IncomeSourceFiltersSection? = nil
    private var expenseSourceFiltersSection: ExpenseSourceFiltersSection? = nil
    private var expenseCategoryFiltersSection: ExpenseCategoryFiltersSection? = nil
    private var safeActiveFiltersSection: SafeActiveFiltersSection? = nil
    private var riskActiveFiltersSection: RiskActiveFiltersSection? = nil
    
    private var sections: [FiltersSelectionViewSection] = []
    
    var selectedFilters: [TransactionableFilter] {
        let filtersSections: [TransactionableFiltersSection?] =
            [expenseSourceFiltersSection,
             incomeSourceFiltersSection,
             expenseCategoryFiltersSection,
             safeActiveFiltersSection,
             riskActiveFiltersSection]
        
        return filtersSections.compactMap { $0 }.flatMap { $0.selectedFilters }
    }
    
    var saveButtonTitle: String {
        return "Выбрать (\(selectedFilters.count))"
    }
    
    var numberOfSections: Int {
        return sections.count
    }
    
    init(incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol,
         expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol,
         expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol,
         activesCoordinator: ActivesCoordinatorProtocol) {
        self.incomeSourcesCoordinator = incomeSourcesCoordinator
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
        self.expenseCategoriesCoordinator = expenseCategoriesCoordinator
        self.activesCoordinator = activesCoordinator
    }
    
    func set(filters: [TransactionableFilter]) {
        transactionableFilters = filters
    }
    
    func resetFilters() {
        selectedFilters.compactMap { $0 as? SelectableTransactionableFilter }.forEach { $0.deselect() }
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
    
    func filterViewModel(at indexPath: IndexPath) -> SelectableTransactionableFilter? {
        guard let section = section(at: indexPath.section) as? TransactionableFiltersSection else { return nil }
        return section.filterViewModel(at: indexPath.row)
    }
    
    func loadFilters() -> Promise<Void> {
        return  firstly {
                    when(fulfilled: loadIncomeSourceFilters(),
                                    loadExpenseSourceFilters(),
                                    loadExpenseCategoryFilters(),
                                    loadActiveFilters(basketType: .safe),
                                    loadActiveFilters(basketType: .risk))
                }.ensure {
                    self.setupSections()
                }
    }
    
    private func setupSections() {
        let collection: [FiltersSelectionViewSection?] = [expenseSourceFiltersSection,
                                                          incomeSourceFiltersSection,
                                                          expenseCategoryFiltersSection,
                                                          safeActiveFiltersSection,
                                                          riskActiveFiltersSection]
        sections = collection.compactMap { $0 }
    }
    
    private func loadIncomeSourceFilters() -> Promise<Void> {
        return  firstly {
                    incomeSourcesCoordinator.index(noBorrows: false)
                }.get { incomeSources in
                    let incomeSourceFilters: [IncomeSourceFilter] = incomeSources.map { incomeSource in
                        
                        let incomeSourceViewModel = IncomeSourceViewModel(incomeSource: incomeSource)
                        let isSelected = self.passedFiltersHash[.incomeSource]?[incomeSource.id] != nil
                        
                        return IncomeSourceFilter(incomeSourceViewModel: incomeSourceViewModel,
                                                                    isSelected: isSelected)
                    }
                    self.incomeSourceFiltersSection = IncomeSourceFiltersSection(incomeSourceFilters: incomeSourceFilters)
                }.asVoid()
    }
    
    private func loadExpenseSourceFilters() -> Promise<Void> {
        return  firstly {
                    expenseSourcesCoordinator.index(currency: nil)
                }.get { expenseSources in
                    let expenseSourceFilters: [ExpenseSourceFilter] = expenseSources.map { expenseSource in
                        
                        let expenseSourceViewModel = ExpenseSourceViewModel(expenseSource: expenseSource)
                        let isSelected = self.passedFiltersHash[.expenseSource]?[expenseSource.id] != nil
                        
                        return ExpenseSourceFilter(expenseSourceViewModel: expenseSourceViewModel,
                                                                    isSelected: isSelected)
                    }
                    self.expenseSourceFiltersSection = ExpenseSourceFiltersSection(expenseSourceFilters: expenseSourceFilters)
                }.asVoid()
    }
    
    private func loadExpenseCategoryFilters() -> Promise<Void> {
        return  firstly {
                    expenseCategoriesCoordinator.index(for: .joy, noBorrows: false)
                }.get { expenseCategories in
                    let expenseCategoryFilters: [ExpenseCategoryFilter] = expenseCategories.map { expenseCategory in
                        
                        let expenseCategoryViewModel = ExpenseCategoryViewModel(expenseCategory: expenseCategory)
                        let isSelected = self.passedFiltersHash[.expenseCategory]?[expenseCategory.id] != nil
                        
                        return ExpenseCategoryFilter(expenseCategoryViewModel: expenseCategoryViewModel,
                                                                    isSelected: isSelected)
                    }
                    self.expenseCategoryFiltersSection = ExpenseCategoryFiltersSection(expenseCategoryFilters: expenseCategoryFilters)
                }.asVoid()
    }
    
    private func loadActiveFilters(basketType: BasketType) -> Promise<Void> {
        return  firstly {
                    activesCoordinator.indexActives(for: basketType)
                }.get { actives in
                    let activeFilters: [ActiveFilter] = actives.map { active in
                        
                        let activeViewModel = ActiveViewModel(active: active)
                        let isSelected = self.passedFiltersHash[.active]?[active.id] != nil
                        
                        return ActiveFilter(activeViewModel: activeViewModel,
                                            isSelected: isSelected)
                    }
                    self.set(activeFilters: activeFilters, by: basketType)
                }.asVoid()
    }

    private func set(activeFilters: [ActiveFilter], by basketType: BasketType) {
        switch basketType {
        case .safe:
            safeActiveFiltersSection = SafeActiveFiltersSection(safeActiveFilters: activeFilters)
        case .risk:
            riskActiveFiltersSection = RiskActiveFiltersSection(riskActiveFilters: activeFilters)
        default:
            return
        }
    }
    
    private func calculatePassedFiltersHash() {
        passedFiltersHash = [TransactionableType : [Int : TransactionableFilter]]()
        
        for filter in transactionableFilters {
            if passedFiltersHash[filter.type] == nil {
                passedFiltersHash[filter.type] = [Int : TransactionableFilter]()
            }
            passedFiltersHash[filter.type]?[filter.id] = filter
        }
    }
}
