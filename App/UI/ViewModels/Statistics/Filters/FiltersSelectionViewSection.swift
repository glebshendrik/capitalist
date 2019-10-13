//
//  FiltersSelectionViewSection.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 02/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

protocol FiltersSelectionViewSection {
    var numberOfRows: Int { get }
    var title: String? { get }
}

class DateRangeFilterSection : FiltersSelectionViewSection {
    var numberOfRows: Int { return 1 }
    var title: String? { return "Выбор периода" }
}

class SourceOrDestinationTransactionFiltersSection : FiltersSelectionViewSection {
    var numberOfRows: Int { return filters.count }
    var title: String?
    
    private let filters: [SelectableSourceOrDestinationTransactionFilter]
    
    var selectedFilters: [SourceOrDestinationTransactionFilter] {
        return filters.filter { $0.isSelected } 
    }
    
    init(title: String, filters: [SelectableSourceOrDestinationTransactionFilter]) {
        self.title = title
        self.filters = filters
    }
    
    func filterViewModel(at index: Int) -> SelectableSourceOrDestinationTransactionFilter? {
        return filters.item(at: index)
    }
}

class IncomeSourceFiltersSection : SourceOrDestinationTransactionFiltersSection {
    
    init(incomeSourceFilters: [IncomeSourceTransactionFilter]) {
        super.init(title: "Источники доходов", filters: incomeSourceFilters)
    }    
}

class ExpenseSourceFiltersSection : SourceOrDestinationTransactionFiltersSection {
    
    init(expenseSourceFilters: [ExpenseSourceTransactionFilter]) {
        super.init(title: "Кошельки", filters: expenseSourceFilters)
    }
}

class JoyExpenseCategoryFiltersSection : SourceOrDestinationTransactionFiltersSection {
    
    init(joyExpenseCategoryFilters: [ExpenseCategoryTransactionFilter]) {
        super.init(title: "Категории трат: удовольствие", filters: joyExpenseCategoryFilters)
    }
}

class RiskExpenseCategoryFiltersSection : SourceOrDestinationTransactionFiltersSection {
    
    init(riskExpenseCategoryFilters: [ExpenseCategoryTransactionFilter]) {
        super.init(title: "Категории трат: риск", filters: riskExpenseCategoryFilters)
    }
}

class SafeExpenseCategoryFiltersSection : SourceOrDestinationTransactionFiltersSection {
    
    init(safeExpenseCategoryFilters: [ExpenseCategoryTransactionFilter]) {
        super.init(title: "Категории трат: безопасность", filters: safeExpenseCategoryFilters)
    }
}
