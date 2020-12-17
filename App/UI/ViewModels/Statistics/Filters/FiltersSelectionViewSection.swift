//
//  FiltersSelectionViewSection.swift
//  Capitalist
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
        return filters[safe: index]
    }
}

class IncomeSourceFiltersSection : TransactionableFiltersSection {
    init(incomeSourceFilters: [IncomeSourceFilter]) {
        super.init(title: NSLocalizedString("Источники доходов", comment: "Источники доходов"), filters: incomeSourceFilters)
    }    
}

class ExpenseSourceFiltersSection : TransactionableFiltersSection {
    init(expenseSourceFilters: [ExpenseSourceFilter]) {
        super.init(title: NSLocalizedString("Кошельки", comment: "Кошельки"), filters: expenseSourceFilters)
    }
}

class ExpenseCategoryFiltersSection : TransactionableFiltersSection {
    init(expenseCategoryFilters: [ExpenseCategoryFilter]) {
        super.init(title: NSLocalizedString("Расходы", comment: "Расходы"), filters: expenseCategoryFilters)
    }
}

class SafeActiveFiltersSection : TransactionableFiltersSection {
    init(safeActiveFilters: [ActiveFilter]) {
        super.init(title: NSLocalizedString("Сбережения", comment: "Сбережения"), filters: safeActiveFilters)
    }
}

class RiskActiveFiltersSection : TransactionableFiltersSection {    
    init(riskActiveFilters: [ActiveFilter]) {
        super.init(title: NSLocalizedString("Инвестиции", comment: "Инвестиции"), filters: riskActiveFilters)
    }
}
