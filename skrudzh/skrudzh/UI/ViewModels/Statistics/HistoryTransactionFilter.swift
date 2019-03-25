//
//  HistoryTransactionFilter.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 22/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation

protocol HistoryTransactionFilter {
    var title: String { get }
}

class SourceOrDestinationHistoryTransactionFilter : HistoryTransactionFilter {
    var id: Int
    var title: String
    var type: HistoryTransactionSourceOrDestinationType
    
    init(id: Int, title: String, type: HistoryTransactionSourceOrDestinationType) {
        self.id = id
        self.title = title
        self.type = type
    }
}

class IncomeSourceHistoryTransactionFilter : SourceOrDestinationHistoryTransactionFilter {
    let incomeSourceViewModel: IncomeSourceViewModel
    
    init(incomeSourceViewModel: IncomeSourceViewModel) {
        self.incomeSourceViewModel = incomeSourceViewModel
        super.init(id: incomeSourceViewModel.id, title: incomeSourceViewModel.name, type: .incomeSource)
    }
}

class ExpenseSourceHistoryTransactionFilter : SourceOrDestinationHistoryTransactionFilter {
    let expenseSourceViewModel: ExpenseSourceViewModel
    
    init(expenseSourceViewModel: ExpenseSourceViewModel) {
        self.expenseSourceViewModel = expenseSourceViewModel
        super.init(id: expenseSourceViewModel.id, title: expenseSourceViewModel.name, type: .expenseSource)
    }
}

class ExpenseCategoryHistoryTransactionFilter : SourceOrDestinationHistoryTransactionFilter {
    let expenseCategoryViewModel: ExpenseCategoryViewModel
    
    init(expenseCategoryViewModel: ExpenseCategoryViewModel) {
        self.expenseCategoryViewModel = expenseCategoryViewModel
        super.init(id: expenseCategoryViewModel.id, title: expenseCategoryViewModel.name, type: .expenseCategory)
    }
}

class DateRangeHistoryTransactionFilter : HistoryTransactionFilter {
    var title: String {
        guard   let fromDateString = fromDateString,
            let toDateString = toDateString else {
                if let fromDateString = self.fromDateString {
                    return "с \(fromDateString)"
                }
                if let toDateString = self.toDateString {
                    return "до \(toDateString)"
                }
                return ""
        }
        return "\(fromDateString) - \(toDateString)"
    }
    
    let fromDate: Date?
    let toDate: Date?
    
    var fromDateString: String? {
        guard let fromDate = fromDate else { return nil }
        return fromDate.dateString(ofStyle: .full)
    }
    
    var toDateString: String? {
        guard let toDate = toDate else { return nil }
        return toDate.dateString(ofStyle: .full)
    }
    
    init(fromDate: Date) {
        self.fromDate = fromDate
        self.toDate = nil
    }
    
    init(toDate: Date) {
        self.fromDate = nil
        self.toDate = toDate
    }
    
    init(fromDate: Date, toDate: Date) {
        self.fromDate = fromDate
        self.toDate = toDate
    }
}
