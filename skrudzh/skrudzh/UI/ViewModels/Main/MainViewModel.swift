//
//  MainViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 12/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class MainViewModel {
    private let incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol
    private let expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol
    private let basketsCoordinator: BasketsCoordinatorProtocol
    private let expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol
    
    private var incomeSourceViewModels: [IncomeSourceViewModel] = []
    private var expenseSourceViewModels: [ExpenseSourceViewModel] = []
    public private(set) var basketsViewModel: BasketsViewModel = BasketsViewModel(baskets: [], basketTypeToSelect: .joy)
    private var joyExpenseCategoryViewModels: [ExpenseCategoryViewModel] = []
    private var riskExpenseCategoryViewModels: [ExpenseCategoryViewModel] = []
    private var safeExpenseCategoryViewModels: [ExpenseCategoryViewModel] = []
    
    var numberOfIncomeSources: Int {
        return incomeSourceViewModels.count + 1
    }
    
    var numberOfExpenseSources: Int {
        return expenseSourceViewModels.count + 1
    }
    
    var numberOfJoyExpenseCategories: Int {
        return numberOfExpenseCategories(with: .joy) + 1
    }
    
    var numberOfRiskExpenseCategories: Int {
        return numberOfExpenseCategories(with: .risk) + 1
    }
    
    var numberOfSafeExpenseCategories: Int {
        return numberOfExpenseCategories(with: .safe) + 1
    }
    
    init(incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol,
         expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol,
         basketsCoordinator: BasketsCoordinatorProtocol,
         expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol) {
        self.incomeSourcesCoordinator = incomeSourcesCoordinator
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
        self.basketsCoordinator = basketsCoordinator
        self.expenseCategoriesCoordinator = expenseCategoriesCoordinator
    }
    
    func loadIncomeSources() -> Promise<Void> {
        return  firstly {
                    incomeSourcesCoordinator.index()
                }.get { incomeSources in
                    self.incomeSourceViewModels = incomeSources.map { IncomeSourceViewModel(incomeSource: $0)}
                }.asVoid()
    }
    
    func loadExpenseSources() -> Promise<Void> {
        return  firstly {
                    expenseSourcesCoordinator.index()
                }.get { expenseSources in
                    self.expenseSourceViewModels = expenseSources.map { ExpenseSourceViewModel(expenseSource: $0)}
                }.asVoid()
    }
    
    func loadBaskets() -> Promise<Void> {
        return  firstly {
                    basketsCoordinator.index()
                }.get { baskets in
                    self.basketsViewModel = BasketsViewModel(baskets: baskets, basketTypeToSelect: self.basketsViewModel.selectedBasketType)
                }.asVoid()
    }
    
    func loadExpenseCategories(by basketType: BasketType) -> Promise<Void> {
        
        return  firstly {
                    expenseCategoriesCoordinator.index(for: basketType)
                }.get { expenseCategories in
                    
                    let expenseCategoryViewModels = expenseCategories.map { ExpenseCategoryViewModel(expenseCategory: $0)}
                    
                    switch basketType {
                    case .joy:
                        self.joyExpenseCategoryViewModels = expenseCategoryViewModels
                    case .risk:
                        self.riskExpenseCategoryViewModels = expenseCategoryViewModels
                    case .safe:
                        self.safeExpenseCategoryViewModels = expenseCategoryViewModels
                    }

                }.asVoid()
    }
    
    func isAddIncomeSourceItem(indexPath: IndexPath) -> Bool {
        return indexPath.row == incomeSourceViewModels.count
    }
    
    func incomeSourceViewModel(at indexPath: IndexPath) -> IncomeSourceViewModel? {
        return incomeSourceViewModels.item(at: indexPath.row)
    }
    
    func isAddExpenseSourceItem(indexPath: IndexPath) -> Bool {
        return indexPath.row == expenseSourceViewModels.count
    }
    
    func expenseSourceViewModel(at indexPath: IndexPath) -> ExpenseSourceViewModel? {
        return expenseSourceViewModels.item(at: indexPath.row)
    }
    
    func expenseCategoryViewModel(at indexPath: IndexPath, basketType: BasketType) -> ExpenseCategoryViewModel? {
        return expenseCategoryViewModels(by: basketType).item(at: indexPath.row)
    }
    
    func isAddCategoryItem(indexPath: IndexPath, basketType: BasketType) -> Bool {
        return indexPath.row == numberOfExpenseCategories(with: basketType)
    }
    
    private func numberOfExpenseCategories(with basketType: BasketType) -> Int {
        return expenseCategoryViewModels(by: basketType).count
    }
    
    private func expenseCategoryViewModels(by basketType: BasketType) -> [ExpenseCategoryViewModel] {
        switch basketType {
        case .joy:
            return joyExpenseCategoryViewModels
        case .risk:
            return riskExpenseCategoryViewModels
        case .safe:
            return safeExpenseCategoryViewModels
        }
    }
}
