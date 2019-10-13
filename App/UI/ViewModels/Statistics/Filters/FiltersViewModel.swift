//
//  FiltersViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 27/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class FiltersViewModel {
    private let incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol
    private let expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol
    private let expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol
    
    public private(set) var sourceOrDestinationFilters: [SourceOrDestinationTransactionFilter] = []
    public private(set) var dateRangeFilter: DateRangeTransactionFilter? = nil
    
    var dateRangeFilterTitle: String? {
        return dateRangeFilter?.title
    }
    
    var numberOfSourceOrDestinationFilters: Int {
        return sourceOrDestinationFilters.count
    }
    
    var isSingleSourceOrDestinationFilterSelectedAndEditable: Bool {
        guard let singleSourceOrDestinationFilter = singleSourceOrDestinationFilter else { return false }
        return singleSourceOrDestinationFilter.editable
    }
    
    var singleSourceOrDestinationFilter: SourceOrDestinationTransactionFilter? {
        guard sourceOrDestinationFilters.count == 1 else { return nil }
        return sourceOrDestinationFilters.first
    }
    
    var editFilterTitle: String? {
        guard let filter = singleSourceOrDestinationFilter else { return nil }
        switch filter.type {
        case .incomeSource:
            return "Редактировать источник дохода \"\(filter.title)\""
        case .expenseSource:
            return "Редактировать кошелек \"\(filter.title)\""
        case .expenseCategory:
            return "Редактировать категорию трат \"\(filter.title)\""
        default:
            return "Редактировать"
        }
    }
    
    init(incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol,
         expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol,
         expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol) {
        self.incomeSourcesCoordinator = incomeSourcesCoordinator
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
        self.expenseCategoriesCoordinator = expenseCategoriesCoordinator
    }
        
    func reloadFilter() -> Promise<Void> {
        guard let filter = singleSourceOrDestinationFilter else { return Promise.value(()) }        
        switch filter.type {
        case .incomeSource:
            return updateIncomeSourceFilter(with: filter.id)
        case .expenseSource:
            return updateExpenseSourceFilter(with: filter.id)
        default:
            return updateExpenseCategoryFilter(with: filter.id)
        }
    }
    
    func set(sourceOrDestinationFilters: [SourceOrDestinationTransactionFilter]) {
        self.sourceOrDestinationFilters = sourceOrDestinationFilters
    }
    
    func set(dateRangeFilter: DateRangeTransactionFilter?) {
        self.dateRangeFilter = dateRangeFilter
    }
    
    func sourceOrDestinationFilter(at indexPath: IndexPath) -> SourceOrDestinationTransactionFilter? {
        return sourceOrDestinationFilters.item(at: indexPath.row)
    }
    
    private func updateIncomeSourceFilter(with id: Int) -> Promise<Void> {
        return  firstly {
                    incomeSourcesCoordinator.show(by: id)
                }.get { incomeSource in
                    let filter = IncomeSourceTransactionFilter(incomeSourceViewModel: IncomeSourceViewModel(incomeSource: incomeSource))
                    self.set(sourceOrDestinationFilters: [filter])
                }.asVoid()
    }
    
    private func updateExpenseSourceFilter(with id: Int) -> Promise<Void> {
        return  firstly {
                    expenseSourcesCoordinator.show(by: id)
                }.get { expenseSource in
                    let filter = ExpenseSourceTransactionFilter(expenseSourceViewModel: ExpenseSourceViewModel(expenseSource: expenseSource))
                    self.set(sourceOrDestinationFilters: [filter])
                }.asVoid()
    }
    
    private func updateExpenseCategoryFilter(with id: Int) -> Promise<Void> {
        return  firstly {
                    expenseCategoriesCoordinator.show(by: id)
                }.get { expenseCategory in
                    let filter = ExpenseCategoryTransactionFilter(expenseCategoryViewModel: ExpenseCategoryViewModel(expenseCategory: expenseCategory))
                    self.set(sourceOrDestinationFilters: [filter])
                }.asVoid()
    }
}
