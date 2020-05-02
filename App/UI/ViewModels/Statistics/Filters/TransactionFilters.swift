//
//  TransactionFilter.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 22/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

protocol TransactionFilter {
    var title: String { get }
}

class TransactionableFilter : TransactionFilter {
    var id: Int
    var title: String
    var type: TransactionableType
    var iconURL: URL?
    var iconPlaceholder: String
    
    var iconType: IconType {
        return iconURL?.absoluteString.components(separatedBy: ".").last == "svg" ? .vector : .raster
    }
    
    init(id: Int, title: String, type: TransactionableType, iconURL: URL?, iconPlaceholder: String) {
        self.id = id
        self.title = title
        self.type = type
        self.iconURL = iconURL
        self.iconPlaceholder = iconPlaceholder
    }
}

class SelectableTransactionableFilter : TransactionableFilter {
    public private(set) var isSelected: Bool
    
    init(id: Int, title: String, type: TransactionableType, iconURL: URL?, iconPlaceholder: String, isSelected: Bool = false) {
        self.isSelected = isSelected
        super.init(id: id, title: title, type: type, iconURL: iconURL, iconPlaceholder: iconPlaceholder)
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

class IncomeSourceFilter : SelectableTransactionableFilter {
    let incomeSourceViewModel: IncomeSourceViewModel
        
    init(incomeSourceViewModel: IncomeSourceViewModel, isSelected: Bool = false) {
        self.incomeSourceViewModel = incomeSourceViewModel
        super.init(id: incomeSourceViewModel.id, title: incomeSourceViewModel.name, type: .incomeSource, iconURL: incomeSourceViewModel.iconURL, iconPlaceholder: incomeSourceViewModel.defaultIconName, isSelected: isSelected)
    }
}

class ExpenseSourceFilter : SelectableTransactionableFilter {
    let expenseSourceViewModel: ExpenseSourceViewModel
        
    init(expenseSourceViewModel: ExpenseSourceViewModel, isSelected: Bool = false) {
        self.expenseSourceViewModel = expenseSourceViewModel
        super.init(id: expenseSourceViewModel.id, title: expenseSourceViewModel.name, type: .expenseSource, iconURL: expenseSourceViewModel.iconURL, iconPlaceholder: expenseSourceViewModel.defaultIconName, isSelected: isSelected)
    }
}

class ExpenseCategoryFilter : SelectableTransactionableFilter {
    let expenseCategoryViewModel: ExpenseCategoryViewModel
    
    var basketType: BasketType {
        return expenseCategoryViewModel.basketType
    }
    
    init(expenseCategoryViewModel: ExpenseCategoryViewModel, isSelected: Bool = false) {
        self.expenseCategoryViewModel = expenseCategoryViewModel
        super.init(id: expenseCategoryViewModel.id, title: expenseCategoryViewModel.name, type: .expenseCategory, iconURL: expenseCategoryViewModel.iconURL, iconPlaceholder: expenseCategoryViewModel.defaultIconName, isSelected: isSelected)
    }
}

class ActiveFilter : SelectableTransactionableFilter {
    let activeViewModel: ActiveViewModel
    
    var basketType: BasketType {
        return activeViewModel.basketType
    }
    
    init(activeViewModel: ActiveViewModel, isSelected: Bool = false) {
        self.activeViewModel = activeViewModel
        super.init(id: activeViewModel.id, title: activeViewModel.name, type: .active, iconURL: activeViewModel.iconURL, iconPlaceholder: activeViewModel.defaultIconName, isSelected: isSelected)
    }
}
