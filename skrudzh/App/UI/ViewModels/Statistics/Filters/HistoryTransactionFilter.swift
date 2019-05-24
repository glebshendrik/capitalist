//
//  HistoryTransactionFilter.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 22/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

protocol HistoryTransactionFilter {
    var title: String { get }
    var editable: Bool { get }
}

class SourceOrDestinationHistoryTransactionFilter : HistoryTransactionFilter {
    var id: Int
    var title: String
    var type: HistoryTransactionSourceOrDestinationType
    var editable: Bool {
        return false
    }
    
    init(id: Int, title: String, type: HistoryTransactionSourceOrDestinationType) {
        self.id = id
        self.title = title
        self.type = type
    }
}

class SelectableSourceOrDestinationHistoryTransactionFilter : SourceOrDestinationHistoryTransactionFilter {
    public private(set) var isSelected: Bool
    
    init(id: Int, title: String, type: HistoryTransactionSourceOrDestinationType, isSelected: Bool = false) {
        self.isSelected = isSelected
        super.init(id: id, title: title, type: type)
    }
    
    func set(selected: Bool) {
        isSelected = selected
    }
    
    func toggle() {
        set(selected: !isSelected)
    }
    
    func select() {
        set(selected: true)
    }
    
    func deselect() {
        set(selected: false)
    }
}

class IncomeSourceHistoryTransactionFilter : SelectableSourceOrDestinationHistoryTransactionFilter {
    let incomeSourceViewModel: IncomeSourceViewModel
    
    override var editable: Bool {
        return !incomeSourceViewModel.isDeleted
    }
    
    init(incomeSourceViewModel: IncomeSourceViewModel, isSelected: Bool = false) {
        self.incomeSourceViewModel = incomeSourceViewModel
        super.init(id: incomeSourceViewModel.id, title: incomeSourceViewModel.name, type: .incomeSource, isSelected: isSelected)
    }
}

class ExpenseSourceHistoryTransactionFilter : SelectableSourceOrDestinationHistoryTransactionFilter {
    let expenseSourceViewModel: ExpenseSourceViewModel
    
    override var editable: Bool {
        return !expenseSourceViewModel.isDeleted
    }
    
    init(expenseSourceViewModel: ExpenseSourceViewModel, isSelected: Bool = false) {
        self.expenseSourceViewModel = expenseSourceViewModel
        super.init(id: expenseSourceViewModel.id, title: expenseSourceViewModel.name, type: .expenseSource, isSelected: isSelected)
    }
}

class ExpenseCategoryHistoryTransactionFilter : SelectableSourceOrDestinationHistoryTransactionFilter {
    let expenseCategoryViewModel: ExpenseCategoryViewModel
    
    override var editable: Bool {
        return !expenseCategoryViewModel.isDeleted
    }
    
    var basketType: BasketType {
        return expenseCategoryViewModel.basketType
    }
    
    init(expenseCategoryViewModel: ExpenseCategoryViewModel, isSelected: Bool = false) {
        self.expenseCategoryViewModel = expenseCategoryViewModel
        super.init(id: expenseCategoryViewModel.id, title: expenseCategoryViewModel.name, type: .expenseCategory, isSelected: isSelected)
    }
}

class IncludedInBalanceHistoryTransactionFilter : ExpenseCategoryHistoryTransactionFilter {
    
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
    
    var editable: Bool {
        return false
    }
    
    let fromDate: Date?
    let toDate: Date?
    
    var fromDateString: String? {
        guard let fromDate = fromDate else { return nil }
        return fromDate.dateString(ofStyle: .short)
    }
    
    var toDateString: String? {
        guard let toDate = toDate else { return nil }
        return toDate.dateString(ofStyle: .short)
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
    
    init(fromDate: Date?, toDate: Date?) {
        self.fromDate = fromDate
        self.toDate = toDate
    }
}
