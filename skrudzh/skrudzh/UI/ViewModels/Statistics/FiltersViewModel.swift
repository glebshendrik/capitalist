//
//  FiltersViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 27/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation

class FiltersViewModel {
    public private(set) var sourceOrDestinationFilters: [SourceOrDestinationHistoryTransactionFilter] = []
    public private(set) var dateRangeFilter: DateRangeHistoryTransactionFilter? = nil
    
    var dateRangeFilterTitle: String? {
        return dateRangeFilter?.title
    }
    
    var numberOfSourceOrDestinationFilters: Int {
        return sourceOrDestinationFilters.count
    }
    
    var isSingleSourceOrDestinationFilterSelected: Bool {
        return singleSourceOrDestinationFilter != nil
    }
    
    var singleSourceOrDestinationFilter: SourceOrDestinationHistoryTransactionFilter? {
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
        }
    }
    
    func set(sourceOrDestinationFilters: [SourceOrDestinationHistoryTransactionFilter]) {
        self.sourceOrDestinationFilters = sourceOrDestinationFilters
    }
    
    func set(dateRangeFilter: DateRangeHistoryTransactionFilter?) {
        self.dateRangeFilter = dateRangeFilter
    }
    
    func sourceOrDestinationFilter(at indexPath: IndexPath) -> SourceOrDestinationHistoryTransactionFilter? {
        return sourceOrDestinationFilters.item(at: indexPath.row)
    }
}
