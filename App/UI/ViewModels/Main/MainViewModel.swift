//
//  MainViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class MainViewModel {
    private let incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol
    private let expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol
    private let basketsCoordinator: BasketsCoordinatorProtocol
    private let expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol
    private let activesCoordinator: ActivesCoordinatorProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    
    private var incomeSourceViewModels: [IncomeSourceViewModel] = []
    private var expenseSourceViewModels: [ExpenseSourceViewModel] = []
    public private(set) var basketsViewModel: BasketsViewModel = BasketsViewModel(baskets: [], basketTypeToSelect: .joy)
    private var joyExpenseCategoryViewModels: [ExpenseCategoryViewModel] = []
    private var riskActiveViewModels: [ActiveViewModel] = []
    private var safeActiveViewModels: [ActiveViewModel] = []
    
    private var editing: Bool = false
    
    var numberOfIncomeSources: Int {
        return editing
            ? incomeSourceViewModels.count
            : incomeSourceViewModels.count + 1
    }
    
    var numberOfExpenseSources: Int {
        return editing
            ? expenseSourceViewModels.count
            : expenseSourceViewModels.count + 1
    }
    
    var numberOfJoyExpenseCategories: Int {
        return editing
            ? numberOfExpenseCategories()
            : numberOfExpenseCategories() + 1
    }
    
    var numberOfRiskActives: Int {
        return editing
            ? numberOfActives(with: .risk)
            : numberOfActives(with: .risk) + 1
    }
    
    var numberOfSafeActives: Int {
        return editing
            ? numberOfActives(with: .safe)
            : numberOfActives(with: .safe) + 1
    }
    
    var balance: String = ""
    var spent: String = ""
    var planned: String = ""
    
    init(incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol,
         expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol,
         basketsCoordinator: BasketsCoordinatorProtocol,
         expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol,
         activesCoordinator: ActivesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol) {
        self.incomeSourcesCoordinator = incomeSourcesCoordinator
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
        self.basketsCoordinator = basketsCoordinator
        self.expenseCategoriesCoordinator = expenseCategoriesCoordinator
        self.activesCoordinator = activesCoordinator
        self.accountCoordinator = accountCoordinator
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
                    expenseSourcesCoordinator.index(noDebts: false, accountType: nil, currency: nil)
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
    
    func loadExpenseCategories() -> Promise<Void> {
        return  firstly {
                    expenseCategoriesCoordinator.index(for: .joy)
                }.get { expenseCategories in
                    self.joyExpenseCategoryViewModels = expenseCategories.map { ExpenseCategoryViewModel(expenseCategory: $0) }
                }.asVoid()
    }
    
    func loadActives(by basketType: BasketType) -> Promise<Void> {
        return  firstly {
                    activesCoordinator.indexActives(for: basketType)
                }.get { actives in
                    
                    let activeViewModels = actives.map { ActiveViewModel(active: $0)}
                    
                    switch basketType {
                    case .risk:
                        self.riskActiveViewModels = activeViewModels
                    case .safe:
                        self.safeActiveViewModels = activeViewModels
                    default:
                        return
                    }
                }.asVoid()
    }
    
    func loadBudget() -> Promise<Void> {
        return  firstly {
                    accountCoordinator.loadCurrentUserBudget()
                }.get { budget in
                    let budgetViewModel = BudgetViewModel(budget: budget)
                    self.balance = budgetViewModel.balanceRounded
                    self.spent = budgetViewModel.spent
                    self.planned = budgetViewModel.planned
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
    
    func expenseCategoryViewModel(at indexPath: IndexPath) -> ExpenseCategoryViewModel? {
        return expenseCategoryViewModels().item(at: indexPath.row)
    }
    
    func activeViewModel(at indexPath: IndexPath, basketType: BasketType) -> ActiveViewModel? {
        return activeViewModels(by: basketType).item(at: indexPath.row)
    }
    
    func isAddCategoryItem(indexPath: IndexPath) -> Bool {
        return indexPath.row == numberOfExpenseCategories()
    }
    
    func isAddActiveItem(indexPath: IndexPath, basketType: BasketType) -> Bool {
        return indexPath.row == numberOfActives(with: basketType)
    }
    
    func set(editing: Bool) {
        self.editing = editing
    }
    
    func moveIncomeSource(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) -> Promise<Void> {
        let movingIncomeSource = incomeSourceViewModels.remove(at: sourceIndexPath.item)
        incomeSourceViewModels.insert(movingIncomeSource, at: destinationIndexPath.item)
        
        return  firstly {
                    incomeSourcesCoordinator.updatePosition(with: IncomeSourcePositionUpdatingForm(id: movingIncomeSource.id,
                                                                                                   position: destinationIndexPath.item))
                }.then {
                    self.loadIncomeSources()
                }
    }
    
    func moveExpenseSource(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) -> Promise<Void> {
        let movingExpenseSource = expenseSourceViewModels.remove(at: sourceIndexPath.item)
        expenseSourceViewModels.insert(movingExpenseSource, at: destinationIndexPath.item)
        
        return  firstly {
                    expenseSourcesCoordinator.updatePosition(with: ExpenseSourcePositionUpdatingForm(id: movingExpenseSource.id,
                                                                                           position: destinationIndexPath.item))
                }.then {
                    self.loadExpenseSources()
                }
    }
    
    func moveJoyExpenseCategory(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) -> Promise<Void> {
        
        let movingExpenseCategory = joyExpenseCategoryViewModels.remove(at: sourceIndexPath.item)
        joyExpenseCategoryViewModels.insert(movingExpenseCategory, at: destinationIndexPath.item)
        
        return move(expenseCategory: movingExpenseCategory.expenseCategory, to: destinationIndexPath.item)
    }
    
    func move(expenseCategory: ExpenseCategory, to position: Int) -> Promise<Void> {
        let updatePositionForm = ExpenseCategoryPositionUpdatingForm(id: expenseCategory.id,
                                                                     position: position)
        return  firstly {
                    expenseCategoriesCoordinator.updatePosition(with: updatePositionForm)
                }.then {
                    self.loadExpenseCategories()
                }
    }
    
    
    func moveActive(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath, basketType: BasketType) -> Promise<Void> {
        
        switch basketType {
        case .joy:
            return Promise.value(())
        case .risk:
            return moveRiskActive(from: sourceIndexPath, to: destinationIndexPath)
        case .safe:
            return moveSafeActive(from: sourceIndexPath, to: destinationIndexPath)
        }
    }
    
    func moveRiskActive(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) -> Promise<Void> {
        
        let movingActive = riskActiveViewModels.remove(at: sourceIndexPath.item)
        riskActiveViewModels.insert(movingActive, at: destinationIndexPath.item)
        
        return move(active: movingActive.active, to: destinationIndexPath.item)
    }
    
    func moveSafeActive(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) -> Promise<Void> {
        
        let movingActive = safeActiveViewModels.remove(at: sourceIndexPath.item)
        safeActiveViewModels.insert(movingActive, at: destinationIndexPath.item)
        
        return move(active: movingActive.active, to: destinationIndexPath.item)
    }
    
    func move(active: Active, to position: Int) -> Promise<Void> {
        let updatePositionForm = ActivePositionUpdatingForm(id: active.id,
                                                                     position: position)
        return  firstly {
                    activesCoordinator.updatePosition(with: updatePositionForm)
                }.then {
                    self.loadActives(by: active.basketType)
                }
    }
    
    
    
    func removeIncomeSource(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return incomeSourcesCoordinator.destroy(by: id, deleteTransactions: deleteTransactions)
    }
    
    func removeExpenseSource(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return expenseSourcesCoordinator.destroy(by: id, deleteTransactions: deleteTransactions)
    }
    
    func removeExpenseCategory(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return expenseCategoriesCoordinator.destroy(by: id, deleteTransactions: deleteTransactions)
    }
    
    func removeActive(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return activesCoordinator.destroyActive(by: id, deleteTransactions: deleteTransactions)
    }
    
    private func numberOfExpenseCategories() -> Int {
        return joyExpenseCategoryViewModels.count
    }
    
    private func expenseCategoryViewModels() -> [ExpenseCategoryViewModel] {
        return joyExpenseCategoryViewModels
    }
    
    private func numberOfActives(with basketType: BasketType) -> Int {
        
        return activeViewModels(by: basketType).count
    }
    
    private func activeViewModels(by basketType: BasketType) -> [ActiveViewModel] {
        switch basketType {
        case .joy:
            return []
        case .risk:
            return riskActiveViewModels
        case .safe:
            return safeActiveViewModels
        }
    }
}
