//
//  DateRangeTransactionFilter.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 27.12.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class DateRangeTransactionFilter : TransactionFilter {
    let fromDate: Date?
    let toDate: Date?
    let datePeriod: DatePeriod
        
    var title: String {
        return datePeriod.formatPeriod(from: fromDate, to: toDate)
    }
    
    init(datePeriod: DatePeriod) {
        self.datePeriod = datePeriod
        if let unit = datePeriod.addingUnit {
            fromDate = Date().dateAtStartOf(unit)
            toDate = Date().dateAtEndOf(unit)
        }
        else {
            fromDate = Date()?.adding(.year, value: -3)
            toDate = Date()
        }
    }
        
    init(fromDate: Date, toDate: Date, datePeriod: DatePeriod) {
        self.fromDate = fromDate
        self.toDate = toDate
        self.datePeriod = datePeriod
    }    
}
