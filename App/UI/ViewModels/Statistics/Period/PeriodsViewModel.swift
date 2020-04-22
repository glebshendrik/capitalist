//
//  PeriodSelectionViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26.12.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import SwiftDate

class PeriodsViewModel {
    
    var dateRangeFilters: [DateRangeTransactionFilter] = []
    
    var numberOfDateRanges: Int {
        return dateRangeFilters.count
    }
    
    var currentDateRangeFilterIndex: Int = 0
    
    var currentDateRangeFilter: DateRangeTransactionFilter? {
        guard dateRangeFilters.count > 0 else { return nil }
        return dateRangeFilters[safe: currentDateRangeFilterIndex]
    }
    
    var currentDateRangeFilterTitle: String? {
        return currentDateRangeFilter?.title
    }
        
    func set(dateRangeFilter: DateRangeTransactionFilter, beginning: Date, ending: Date) {
        dateRangeFilters = calculateRangeFilters(for: dateRangeFilter, beginning: beginning, ending: ending)
        guard dateRangeFilters.count > 0 else {
            currentDateRangeFilterIndex = 0
            return
        }
        currentDateRangeFilterIndex = dateRangeFilters.count - 1
    }
    
    private func calculateRangeFilters(for dateRangeFilter: DateRangeTransactionFilter, beginning: Date, ending: Date) -> [DateRangeTransactionFilter] {
        guard   let from = dateRangeFilter.fromDate,
                let to = dateRangeFilter.toDate,
                to >= from else {

                return []
        }
        
        if dateRangeFilter.datePeriod == .custom || dateRangeFilter.datePeriod == .entire {
            return [dateRangeFilter]
        }
        
        guard let unit = dateRangeFilter.datePeriod.addingUnit else { return []}
        
        var tempDate = beginning.dateAtStartOf(unit)
        var array = [DateRangeTransactionFilter]()

        while tempDate < ending.dateAtEndOf(unit) {
            let nextDate = tempDate + 1.months
            array.append(DateRangeTransactionFilter(fromDate: tempDate, toDate: tempDate.dateAtEndOf(unit), datePeriod: dateRangeFilter.datePeriod))
            tempDate = nextDate
        }

        return array
    }
    
    func rangeTitle(at indexPath: IndexPath) -> String? {
        return dateRangeFilters[safe: indexPath.item]?.title
    }
}
