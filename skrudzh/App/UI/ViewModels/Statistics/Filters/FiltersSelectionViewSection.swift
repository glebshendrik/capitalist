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

class SourceOrDestinationHistoryTransactionFiltersSection : FiltersSelectionViewSection {
    var numberOfRows: Int { return filters.count }
    var title: String?
    
    private let filters: [SelectableSourceOrDestinationHistoryTransactionFilter]
    
    var selectedFilters: [SourceOrDestinationHistoryTransactionFilter] {
        return filters.filter { $0.isSelected } 
    }
    
    init(title: String, filters: [SelectableSourceOrDestinationHistoryTransactionFilter]) {
        self.title = title
        self.filters = filters
    }
    
    func filterViewModel(at index: Int) -> SelectableSourceOrDestinationHistoryTransactionFilter? {
        return filters.item(at: index)
    }
}

class IncomeSourceFiltersSection : SourceOrDestinationHistoryTransactionFiltersSection {
    
    init(incomeSourceFilters: [IncomeSourceHistoryTransactionFilter]) {
        super.init(title: "Источники доходов", filters: incomeSourceFilters)
    }    
}

class ExpenseSourceFiltersSection : SourceOrDestinationHistoryTransactionFiltersSection {
    
    init(expenseSourceFilters: [ExpenseSourceHistoryTransactionFilter]) {
        super.init(title: "Кошельки", filters: expenseSourceFilters)
    }
}

class JoyExpenseCategoryFiltersSection : SourceOrDestinationHistoryTransactionFiltersSection {
    
    init(joyExpenseCategoryFilters: [ExpenseCategoryHistoryTransactionFilter]) {
        super.init(title: "Категории трат: удовольствие", filters: joyExpenseCategoryFilters)
    }
}

class RiskExpenseCategoryFiltersSection : SourceOrDestinationHistoryTransactionFiltersSection {
    
    init(riskExpenseCategoryFilters: [ExpenseCategoryHistoryTransactionFilter]) {
        super.init(title: "Категории трат: риск", filters: riskExpenseCategoryFilters)
    }
}

class SafeExpenseCategoryFiltersSection : SourceOrDestinationHistoryTransactionFiltersSection {
    
    init(safeExpenseCategoryFilters: [ExpenseCategoryHistoryTransactionFilter]) {
        super.init(title: "Категории трат: безопасность", filters: safeExpenseCategoryFilters)
    }
}
