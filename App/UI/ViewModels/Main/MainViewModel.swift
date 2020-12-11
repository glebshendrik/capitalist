//
//  MainViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 12/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit
import Haptica

class MainViewModel {
    private let incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol
    private let expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol
    private let basketsCoordinator: BasketsCoordinatorProtocol
    private let expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol
    private let activesCoordinator: ActivesCoordinatorProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    private let userPreferencesManager: UserPreferencesManagerProtocol
    private let bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol
    
    private var incomeSourceViewModels: [IncomeSourceViewModel] = []
    private var expenseSourceViewModels: [ExpenseSourceViewModel] = []
    public private(set) var basketsViewModel: BasketsViewModel = BasketsViewModel(baskets: [], basketTypeToSelect: .joy)
    private var joyExpenseCategoryViewModels: [ExpenseCategoryViewModel] = []
    private var riskActiveViewModels: [ActiveViewModel] = []
    private var safeActiveViewModels: [ActiveViewModel] = []
    
    public private(set) var budget: BudgetViewModel? = nil
    public private(set) var editing: Bool = false
    
    private var isUpdatingIncomeSources: Bool = false
    private var isUpdatingExpenseSources: Bool = false
    private var isUpdatingExpenseCategories: Bool = false
    private var isUpdatingInvestments: Bool = false
    private var isUpdatingSavings: Bool = false
    private var isUpdatingBudget: Bool = false
    private var isUpdatingBaskets: Bool = false
    private var isUpdatingMinVersion: Bool = false
    
    private var minVersion: String?
    private var minBuild: String?
    
    init(incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol,
         expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol,
         basketsCoordinator: BasketsCoordinatorProtocol,
         expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol,
         activesCoordinator: ActivesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         userPreferencesManager: UserPreferencesManagerProtocol,
         bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol) {
        self.incomeSourcesCoordinator = incomeSourcesCoordinator
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
        self.basketsCoordinator = basketsCoordinator
        self.expenseCategoriesCoordinator = expenseCategoriesCoordinator
        self.activesCoordinator = activesCoordinator
        self.accountCoordinator = accountCoordinator
        self.userPreferencesManager = userPreferencesManager
        self.bankConnectionsCoordinator = bankConnectionsCoordinator
    }
}

//MARK: Common
extension MainViewModel {
    var fastGesturePressDuration: TimeInterval {
        return Double(userPreferencesManager.fastGesturePressDurationMilliseconds) / 1000.0
    }
    
    var isUpdatingData: Bool {
        return
            isUpdatingIncomeSources ||
            isUpdatingExpenseSources ||
            isUpdatingExpenseCategories ||
            isUpdatingInvestments ||
            isUpdatingSavings ||
            isUpdatingBudget ||
            isUpdatingBaskets ||
            isUpdatingMinVersion
    }
    
    func set(editing: Bool) {
        self.editing = editing
    }
    
    func resetTransactionables() {
        incomeSourceViewModels.forEach { $0.isSelected = false }
        expenseSourceViewModels.forEach { $0.isSelected = false }
        joyExpenseCategoryViewModels.forEach { $0.isSelected = false }
        riskActiveViewModels.forEach { $0.isSelected = false }
        safeActiveViewModels.forEach { $0.isSelected = false }
    }
}

//MARK: App Version
extension MainViewModel {
    var isAppUpdateNeeded: Bool {
        //        return true
        guard   let minBuild = minBuild,
                let appBuild = UIApplication.shared.buildNumber,
                let minBuildNumber = Int(minBuild),
                let appBuildNumber = Int(appBuild) else {
            return false
        }
        return appBuildNumber < minBuildNumber
    }
    
    func checkMinVersion() -> Promise<Void> {
        return
            firstly {
                accountCoordinator.loadCurrentUser()
            }.get { user in
                self.setMinimumAllowed(version: user.minVersion, build: user.minBuild)
            }.asVoid()
    }
    
    private func setMinimumAllowed(version: String?, build: String?) {
        minVersion = version
        minBuild = build
    }
}

//MARK: Budget
extension MainViewModel {
    func loadBudget() -> Promise<Void> {
        return
            firstly {
                accountCoordinator.loadCurrentUserBudget()
            }.get { budget in
                self.budget = BudgetViewModel(budget: budget)
            }.asVoid()
    }
}

//MARK: Baskets
extension MainViewModel {
    var basketTotalExpensesTitle: String {
        switch basketsViewModel.selectedBasketType {
            case .joy:
                return NSLocalizedString("Расходы: ", comment: "Расходы: ")
            default:
                return NSLocalizedString("Инвестировано: ", comment: "Инвестировано: ")
        }
    }
    
    var basketTotalExpenses: String {
        return basketsViewModel.selectedBasketSpent ?? ""
    }
    
    var basketTotalTitle: String {
        switch basketsViewModel.selectedBasketType {
            case .safe, .risk:
                return NSLocalizedString(". Стоимость: ", comment: ". Стоимость: ")
            default:
                return ""
        }
    }
    
    var basketTotal: String {
        switch basketsViewModel.selectedBasketType {
            case .safe:
                return budget?.safeActivesAmountRounded ?? ""
            case .risk:
                return budget?.riskActivesAmountRounded ?? ""
            default:
                return ""
        }
    }
    
    func loadBaskets() -> Promise<Void> {
        return
            firstly {
                basketsCoordinator.index()
            }.get { baskets in
                self.basketsViewModel = BasketsViewModel(baskets: baskets, basketTypeToSelect: self.basketsViewModel.selectedBasketType)
            }.asVoid()
    }
}

//MARK: Income Sources
extension MainViewModel {
    var numberOfIncomeSources: Int {
        return editing
            ? incomeSourceViewModels.count
            : incomeSourceViewModels.count + 1
    }
    
    var incomesAmountRounded: String? {
        return budget?.incomesAmountRounded
    }
    
    var hasUnlinkedIncomeSources: Bool {
        return incomeSourceViewModels.any { $0.isTreatedAsUnlinked }
    }
    
    func incomeSourceViewModel(at indexPath: IndexPath) -> IncomeSourceViewModel? {
        return incomeSourceViewModels[safe: indexPath.row]
    }
    
    func isAddIncomeSourceItem(indexPath: IndexPath) -> Bool {
        return indexPath.row == incomeSourceViewModels.count
    }
    
    func loadIncomeSources() -> Promise<Void> {
        isUpdatingIncomeSources = true
        return
            firstly {
                incomeSourcesCoordinator.index(noBorrows: false)
            }.get { incomeSources in
                self.incomeSourceViewModels = incomeSources.map { IncomeSourceViewModel(incomeSource: $0)}
                self.resetTransactionables()
            }.ensure {
                self.isUpdatingIncomeSources = false
            }.asVoid()
    }
    
    func moveIncomeSource(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) -> Promise<Void> {
        let movingIncomeSource = incomeSourceViewModels.remove(at: sourceIndexPath.item)
        incomeSourceViewModels.insert(movingIncomeSource, at: destinationIndexPath.item)
        
        return
            firstly {
                incomeSourcesCoordinator.updatePosition(with: IncomeSourcePositionUpdatingForm(id: movingIncomeSource.id,
                                                                                               position: destinationIndexPath.item))
            }.then {
                self.loadIncomeSources()
            }
    }
    
    func removeIncomeSource(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return incomeSourcesCoordinator.destroy(by: id, deleteTransactions: deleteTransactions)
    }
}

//MARK: Expense Sources
extension MainViewModel {
    var numberOfExpenseSources: Int {
        return editing
            ? expenseSourceViewModels.count
            : expenseSourceViewModels.count + 1
    }
    
    var expenseSourcesAmountRounded: String? {
        return budget?.expenseSourcesAmountRounded
    }
    
    var hasUnlinkedExpenseSources: Bool {
        return expenseSourceViewModels.any { $0.isTreatedAsUnlinked }
    }
    
    func isAddExpenseSourceItem(indexPath: IndexPath) -> Bool {
        return indexPath.row == expenseSourceViewModels.count
    }
    
    func expenseSourceViewModel(at indexPath: IndexPath) -> ExpenseSourceViewModel? {
        return expenseSourceViewModels[safe: indexPath.row]
    }
    
    func expenseSource(by id: Int) -> ExpenseSourceViewModel? {
        return expenseSourceViewModels.first { $0.expenseSource.id == id }
    }
    
    func loadExpenseSource(id: Int) -> Promise<ExpenseSourceViewModel> {
        if let expenseSource = expenseSource(by: id) {
            return Promise.value(expenseSource)
        }
        return
            firstly {
                expenseSourcesCoordinator.show(by: id)
            }.map {
                ExpenseSourceViewModel(expenseSource: $0)
            }
    }
    
    func loadExpenseSources() -> Promise<Void> {
        return
            firstly {
                expenseSourcesCoordinator.index(currency: nil)
            }.get { expenseSources in
                self.expenseSourceViewModels = expenseSources.map { ExpenseSourceViewModel(expenseSource: $0)}
                self.resetTransactionables()
            }.asVoid()
    }
    
    func moveExpenseSource(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) -> Promise<Void> {
        let movingExpenseSource = expenseSourceViewModels.remove(at: sourceIndexPath.item)
        expenseSourceViewModels.insert(movingExpenseSource, at: destinationIndexPath.item)
        
        return
            firstly {
                expenseSourcesCoordinator.updatePosition(with: ExpenseSourcePositionUpdatingForm(id: movingExpenseSource.id,
                                                                                                 position: destinationIndexPath.item))
            }.then {
                self.loadExpenseSources()
            }
    }
    
    func removeExpenseSource(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return expenseSourcesCoordinator.destroy(by: id, deleteTransactions: deleteTransactions)
    }
}

//MARK: Connections
extension MainViewModel {
    func refreshExpenseSourcesConnections() -> Promise<Void> {
        let promises = expenseSourceViewModels
            .filter { $0.connectionConnected }
            .map { refreshConnection(expenseSourceViewModel: $0) }
        guard promises.count > 0 else { return Promise.value(()) }
        return
            firstly {
                when(fulfilled: promises)
            }.then {
                self.loadExpenseSources()
            }
    }
    
    func refreshConnection(expenseSourceViewModel: ExpenseSourceViewModel) -> Promise<Void> {
        expenseSourceViewModel.isConnectionLoading = true
        return
            firstly {
                expenseSourcesCoordinator.refreshConnection(expenseSource: expenseSourceViewModel.expenseSource)
            }.ensure {
                expenseSourceViewModel.isConnectionLoading = false
            }
    }
}

//MARK: Expense Categories
extension MainViewModel {
    var numberOfJoyExpenseCategories: Int {
        return editing
            ? numberOfExpenseCategories()
            : numberOfExpenseCategories() + 1
    }
    
    var hasUnlinkedExpenseCategories: Bool {
        return joyExpenseCategoryViewModels.any { $0.isTreatedAsUnlinked }
    }
    
    private func numberOfExpenseCategories() -> Int {
        return joyExpenseCategoryViewModels.count
    }
    
    private func expenseCategoryViewModels() -> [ExpenseCategoryViewModel] {
        return joyExpenseCategoryViewModels
    }
    
    func expenseCategoryViewModel(at indexPath: IndexPath) -> ExpenseCategoryViewModel? {
        return expenseCategoryViewModels()[safe: indexPath.row]
    }
    
    func isAddCategoryItem(indexPath: IndexPath) -> Bool {
        return indexPath.row == numberOfExpenseCategories()
    }
    
    func loadExpenseCategories() -> Promise<Void> {
        return
            firstly {
                expenseCategoriesCoordinator.index(for: .joy, noBorrows: false)
            }.get { expenseCategories in
                self.joyExpenseCategoryViewModels = expenseCategories.map { ExpenseCategoryViewModel(expenseCategory: $0) }
                self.resetTransactionables()
            }.asVoid()
    }
    
    func moveJoyExpenseCategory(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) -> Promise<Void> {
        
        let movingExpenseCategory = joyExpenseCategoryViewModels.remove(at: sourceIndexPath.item)
        joyExpenseCategoryViewModels.insert(movingExpenseCategory, at: destinationIndexPath.item)
        
        return move(expenseCategory: movingExpenseCategory.expenseCategory, to: destinationIndexPath.item)
    }
    
    func move(expenseCategory: ExpenseCategory, to position: Int) -> Promise<Void> {
        let updatePositionForm = ExpenseCategoryPositionUpdatingForm(id: expenseCategory.id,
                                                                     position: position)
        return
            firstly {
                expenseCategoriesCoordinator.updatePosition(with: updatePositionForm)
            }.then {
                self.loadExpenseCategories()
            }
    }
    
    func removeExpenseCategory(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return expenseCategoriesCoordinator.destroy(by: id, deleteTransactions: deleteTransactions)
    }
}

//MARK: Actives
extension MainViewModel {
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
    
    func isAddActiveItem(indexPath: IndexPath, basketType: BasketType) -> Bool {
        return indexPath.row == numberOfActives(with: basketType)
    }
    
    func activeViewModel(at indexPath: IndexPath, basketType: BasketType) -> ActiveViewModel? {
        return activeViewModels(by: basketType)[safe: indexPath.row]
    }
    
    func loadActives(by basketType: BasketType) -> Promise<Void> {
        return
            firstly {
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
                self.resetTransactionables()
            }.asVoid()
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
        return
            firstly {
                activesCoordinator.updatePosition(with: updatePositionForm)
            }.then {
                self.loadActives(by: active.basketType)
            }
    }
    
    func removeActive(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return activesCoordinator.destroyActive(by: id, deleteTransactions: deleteTransactions)
    }
}
