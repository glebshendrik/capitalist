//
//  DatePeriodSelectionViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 28.12.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class DatePeriodSelectionViewModel {
    let datePeriods: [DatePeriod] = DatePeriod.all
        
    public private(set) var selectedDatePeriod: DatePeriod = DatePeriod.month
    
    public private(set) var fromDate: Date? {
        didSet {
            toDateMinDate = fromDate
        }
    }
    
    public private(set) var toDate: Date? {
        didSet {
            fromDateMaxDate = toDate
        }
    }
    
    public private(set) var fromDateMaxDate: Date?
    public private(set) var toDateMinDate: Date?
    
    private var transactionsMinDate: Date?
    private var transactionsMaxDate: Date?
    
    var fromDateFormatted: String? {
        return fromDate?.dateString(ofStyle: .short)
    }
    
    var toDateFormatted: String? {
        return toDate?.dateString(ofStyle: .short)
    }
    
    var useCustomDatesSwitchOn: Bool {
        return selectedDatePeriod == .custom
    }
    
    var selectedDateRangeFilter: DateRangeTransactionFilter? {
        guard   let from = fromDate,
                let to = toDate else {
                return nil
        }
        return DateRangeTransactionFilter(fromDate: from, toDate: to, datePeriod: selectedDatePeriod)
    }
    
    var passedDateRangeFilter: DateRangeTransactionFilter?
    
    var filterChanged: Bool {
        let newFilter = selectedDateRangeFilter
        return  newFilter?.datePeriod != passedDateRangeFilter?.datePeriod ||
                newFilter?.fromDate != passedDateRangeFilter?.fromDate ||
                newFilter?.toDate != passedDateRangeFilter?.toDate
    }
    
    func set(dateRangeFilter: DateRangeTransactionFilter?, transactionsMinDate: Date?, transactionsMaxDate: Date?) {
        passedDateRangeFilter = dateRangeFilter
        self.transactionsMinDate = transactionsMinDate
        self.transactionsMaxDate = transactionsMaxDate
        set(datePeriod: dateRangeFilter?.datePeriod ?? .month)
        fromDate = dateRangeFilter?.fromDate
        toDate = dateRangeFilter?.toDate        
    }
    
    func reset() {
        set(datePeriod: .month)
    }
    
    func set(fromDate: Date) {
        self.fromDate = fromDate
        selectedDatePeriod = .custom
    }
    
    func set(toDate: Date) {
        self.toDate = toDate
        selectedDatePeriod = .custom
    }
    
    func set(datePeriod: DatePeriod) {
        selectedDatePeriod = datePeriod
        if let unit = selectedDatePeriod.addingUnit {
            fromDate = Date().dateAtStartOf(unit)
            toDate = Date().dateAtEndOf(unit)
        }
        else if selectedDatePeriod == .entire {
            fromDate = transactionsMinDate
            toDate = transactionsMaxDate
        }
    }
    
    func set(useCustomPeriod: Bool) {
        set(datePeriod: useCustomPeriod ? .custom : .month)
    }
}
