//
//  BalanceViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum BalanceCategory {
    case expenseSources
    case expenseCategories
}

class BalanceViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    private let expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol
    private let expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol
    
    public private(set) var budgetViewModel: BudgetViewModel? = nil
    private var expenseSourceViewModels: [ExpenseSourceViewModel] = []
    private var expenseCategoryViewModels: [ExpenseCategoryViewModel] = []
    
    var numberOfExpenseSources: Int {
        return expenseSourceViewModels.count
    }
    
    var numberOfExpenseCategories: Int {
        return expenseCategoryViewModels.count
    }
    
    var selectedBalanceCategory: BalanceCategory = .expenseSources
    
    init(accountCoordinator: AccountCoordinatorProtocol,
         expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol,
         expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
        self.expenseCategoriesCoordinator = expenseCategoriesCoordinator
    }
    
    func loadBudget() -> Promise<Void> {
        return  firstly {
                    accountCoordinator.loadCurrentUserBudget()
                }.get { budget in
                    self.budgetViewModel = BudgetViewModel(budget: budget)
                }.asVoid()
    }
    
    func loadExpenseSources() -> Promise<Void> {
        return  firstly {
                    expenseSourcesCoordinator.index(noDebts: true, accountType: nil, currency: nil)
                }.get { expenseSources in
                    self.expenseSourceViewModels = expenseSources
                        .map { ExpenseSourceViewModel(expenseSource: $0)}                        
                }.asVoid()
    }
    
    func loadExpenseCategories() -> Promise<Void> {
        return  firstly {
                    expenseCategoriesCoordinator.index()
                }.get { expenseCategories in
                    self.expenseCategoryViewModels = expenseCategories
                        .map { ExpenseCategoryViewModel(expenseCategory: $0)}
                }.asVoid()
    }
    
    func expenseSourceViewModel(at indexPath: IndexPath) -> ExpenseSourceViewModel? {
        return expenseSourceViewModels.item(at: indexPath.row)
    }
    
    func expenseCategoryViewModel(at indexPath: IndexPath) -> ExpenseCategoryViewModel? {
        return expenseCategoryViewModels.item(at: indexPath.row)
    }
}
