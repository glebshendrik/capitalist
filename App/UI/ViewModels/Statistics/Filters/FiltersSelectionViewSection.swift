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

class TransactionableFiltersSection : FiltersSelectionViewSection {
    var numberOfRows: Int { return filters.count }
    var title: String?
    
    private let filters: [SelectableTransactionableFilter]
    
    var selectedFilters: [TransactionableFilter] {
        return filters.filter { $0.isSelected } 
    }
    
    init(title: String, filters: [SelectableTransactionableFilter]) {
        self.title = title.uppercased()
        self.filters = filters
    }
    
    func filterViewModel(at index: Int) -> SelectableTransactionableFilter? {
        return filters.item(at: index)
    }
}

class IncomeSourceFiltersSection : TransactionableFiltersSection {
    init(incomeSourceFilters: [IncomeSourceFilter]) {
        super.init(title: "Источники доходов", filters: incomeSourceFilters)
    }    
}

class ExpenseSourceFiltersSection : TransactionableFiltersSection {
    init(expenseSourceFilters: [ExpenseSourceFilter]) {
        super.init(title: "Кошельки", filters: expenseSourceFilters)
    }
}

class ExpenseCategoryFiltersSection : TransactionableFiltersSection {
    init(expenseCategoryFilters: [ExpenseCategoryFilter]) {
        super.init(title: "Расходы", filters: expenseCategoryFilters)
    }
}

class SafeActiveFiltersSection : TransactionableFiltersSection {
    init(safeActiveFilters: [ActiveFilter]) {
        super.init(title: "Сбережения", filters: safeActiveFilters)
    }
}

class RiskActiveFiltersSection : TransactionableFiltersSection {    
    init(riskActiveFilters: [ActiveFilter]) {
        super.init(title: "Инвестиции", filters: riskActiveFilters)
    }
}
