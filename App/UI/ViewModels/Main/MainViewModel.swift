//
//  MainViewModel.swift
//  Three Baskets
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
    
    private var incomeSourceViewModels: [IncomeSourceViewModel] = []
    private var expenseSourceViewModels: [ExpenseSourceViewModel] = []
    public private(set) var basketsViewModel: BasketsViewModel = BasketsViewModel(baskets: [], basketTypeToSelect: .joy)
    private var joyExpenseCategoryViewModels: [ExpenseCategoryViewModel] = []
    private var riskActiveViewModels: [ActiveViewModel] = []
    private var safeActiveViewModels: [ActiveViewModel] = []
    
    public private(set) var selectedSource: Transactionable? = nil {
        didSet {
            oldValue?.isSelected = false
            selectedSource?.isSelected = true
        }
    }
    public private(set) var selectedDestination: Transactionable? = nil {
        didSet {
            oldValue?.isSelected = false
            selectedDestination?.isSelected = true
        }
    }
    
    var adviserTip: String? {
        guard selecting else { return nil }
        
        guard let selectedSource = selectedSource else {
            guard let selectedDestination = selectedDestination else {
                return NSLocalizedString("Выберите источник дохода, кошелек или актив", comment: "Выберите источник дохода, кошелек или актив")
            }
            switch selectedDestination.type {
            case .expenseSource:
                return NSLocalizedString("Выберите источник дохода, кошелек или актив", comment: "Выберите источник дохода, кошелек или актив")
            case .expenseCategory:
                return NSLocalizedString("Выберите кошелек", comment: "Выберите кошелек")
            case .active:
                return NSLocalizedString("Выберите источник дохода или кошелек", comment: "Выберите источник дохода или кошелек")
            default:
                return nil
            }
        }
        
        guard selectedDestination == nil else { return nil }
        
        switch selectedSource.type {
        case .incomeSource:
            if let incomeSource = selectedSource as? IncomeSourceViewModel,
                incomeSource.isChild {
                return NSLocalizedString("Выберите кошелек или актив", comment: "Выберите кошелек или актив")
            }
            return NSLocalizedString("Выберите кошелек", comment: "Выберите кошелек")
        case .expenseSource:
            return NSLocalizedString("Выберите кошелек, категорию трат или актив", comment: "Выберите кошелек, категорию трат или актив")
        case .active:
            return NSLocalizedString("Выберите кошелек", comment: "Выберите кошелек")
        default:
            return nil
        }
    }
    
    var selectedSourceName: String {
        return selectedSource?.name ?? "..."
    }
    
    var selectedDestinationName: String {
        return selectedDestination?.name ?? "..."
    }
    
    var transactionablesSelected: Bool {
        return selectedSource != nil && selectedDestination != nil
    }
    
    public private(set) var editing: Bool = false
    public private(set) var selecting: Bool = false
    
    var numberOfIncomeSources: Int {
        return editing || selecting
            ? incomeSourceViewModels.count
            : incomeSourceViewModels.count + 1
    }
    
    var numberOfExpenseSources: Int {
        return editing || selecting
            ? expenseSourceViewModels.count
            : expenseSourceViewModels.count + 1
    }
    
    var numberOfJoyExpenseCategories: Int {
        return editing || selecting
            ? numberOfExpenseCategories()
            : numberOfExpenseCategories() + 1
    }
    
    var numberOfRiskActives: Int {
        return editing || selecting
            ? numberOfActives(with: .risk)
            : numberOfActives(with: .risk) + 1
    }
    
    var numberOfSafeActives: Int {
        return editing || selecting
            ? numberOfActives(with: .safe)
            : numberOfActives(with: .safe) + 1
    }
    
    public private(set) var budget: BudgetViewModel? = nil
    
    var incomesAmountRounded: String? {
        return budget?.incomesAmountRounded
    }
    
    var expenseSourcesAmountRounded: String? {
        return budget?.expenseSourcesAmountRounded
    }
    
    var basketTotalExpensesTitle: String {
        return NSLocalizedString("Расходы: ", comment: "Расходы: ")
    }
    
    var basketTotalExpenses: String {
        return basketsViewModel.selectedBasketSpent ?? ""
    }
    
    var basketTotalTitle: String {
        switch basketsViewModel.selectedBasketType {
        case .safe:
            return NSLocalizedString(". Сбережения: ", comment: ". Сбережения: ")
        case .risk:
            return NSLocalizedString(". Инвестиции: ", comment: ". Инвестиции: ")
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
    
    var fastGesturePressDuration: TimeInterval {
        return Double(userPreferencesManager.fastGesturePressDurationMilliseconds) / 1000.0
    }
    
    init(incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol,
         expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol,
         basketsCoordinator: BasketsCoordinatorProtocol,
         expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol,
         activesCoordinator: ActivesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         userPreferencesManager: UserPreferencesManagerProtocol) {
        self.incomeSourcesCoordinator = incomeSourcesCoordinator
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
        self.basketsCoordinator = basketsCoordinator
        self.expenseCategoriesCoordinator = expenseCategoriesCoordinator
        self.activesCoordinator = activesCoordinator
        self.accountCoordinator = accountCoordinator
        self.userPreferencesManager = userPreferencesManager
    }
    
    func selectSource(_ source: Transactionable) {
        guard canBeSource(source) else { return }
        selectedSource = source
    }
    
    func selectDestination(_ destination: Transactionable) {
        guard canBeDestination(destination) else { return }
        selectedDestination = destination
    }
    
    func canBeSource(_ transactionable: Transactionable) -> Bool {
        guard let source = transactionable as? TransactionSource else { return false }
        
        if  let destination = selectedDestination as? TransactionDestination {
            return destination.isTransactionDestinationFor(transactionSource: source)
        }
        return source.isTransactionSource
    }
    
    func canBeDestination(_ transactionable: Transactionable) -> Bool {
        guard let destination = transactionable as? TransactionDestination else { return false }
        
        if  let source = selectedSource as? TransactionSource {
            return destination.isTransactionDestinationFor(transactionSource: source)
        }
        return true
    }
    
    func select(_ transactionable: Transactionable) {
        if  selectedSource == nil {
            
            selectSource(transactionable)
            return
        }
        else if let source = selectedSource as? TransactionSource,
                    source.type == transactionable.type {
            
            if source.id == transactionable.id {
                selectedSource = nil
                return
            }
            else if !canBeDestination(transactionable) {
                selectSource(transactionable)
                return
            }
//            else if (selectedDestination == nil || selectedDestination!.type == transactionable.type) && canBeDestination(transactionable) {
//                selectDestination(transactionable)
//                return
//            }
//            else if let destination = selectedDestination as? TransactionDestination,
//                        destination.type != transactionable.type {
//                selectSource(transactionable)
//                return
//            }
            
            
        }
        
        if  selectedDestination == nil {
            
            selectDestination(transactionable)
            return
        }
        else if let destination = selectedDestination as? TransactionDestination,
                    destination.type == transactionable.type {
            
            if destination.id == transactionable.id {
                selectedDestination = nil
            }
            else {
                selectDestination(transactionable)
            }
            return
        }
        
        if canBeDestination(transactionable) {
            selectDestination(transactionable)
        }
        else if canBeSource(transactionable) {
            selectSource(transactionable)
        }
    }
    
    func resetTransactionables() {
        selectedSource = nil
        selectedDestination = nil
        incomeSourceViewModels.forEach {
            $0.isSelected = false
        }
        expenseSourceViewModels.forEach {
            $0.isSelected = false
        }
        joyExpenseCategoryViewModels.forEach {
            $0.isSelected = false
        }
        riskActiveViewModels.forEach {
            $0.isSelected = false
        }
        safeActiveViewModels.forEach {
            $0.isSelected = false
        }
    }
    
    func loadIncomeSources() -> Promise<Void> {
        return  firstly {
                    incomeSourcesCoordinator.index(noBorrows: false)
                }.get { incomeSources in
                    self.incomeSourceViewModels = incomeSources.map { IncomeSourceViewModel(incomeSource: $0)}
                    self.resetTransactionables()
                }.asVoid()
    }
    
    func loadExpenseSources() -> Promise<Void> {
        return  firstly {
                    expenseSourcesCoordinator.index(currency: nil)
                }.get { expenseSources in
                    self.expenseSourceViewModels = expenseSources.map { ExpenseSourceViewModel(expenseSource: $0)}
                    self.resetTransactionables()
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
                    expenseCategoriesCoordinator.index(for: .joy, noBorrows: false)
                }.get { expenseCategories in
                    self.joyExpenseCategoryViewModels = expenseCategories.map { ExpenseCategoryViewModel(expenseCategory: $0) }
                    self.resetTransactionables()
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
                    self.resetTransactionables()
                }.asVoid()
    }
    
    func loadBudget() -> Promise<Void> {
        return  firstly {
                    accountCoordinator.loadCurrentUserBudget()
                }.get { budget in
                    self.budget = BudgetViewModel(budget: budget)
                }.asVoid()
    }
    
    func isAddIncomeSourceItem(indexPath: IndexPath) -> Bool {
        return indexPath.row == incomeSourceViewModels.count
    }
    
    func incomeSourceViewModel(at indexPath: IndexPath) -> IncomeSourceViewModel? {
        return incomeSourceViewModels[safe: indexPath.row]
    }
    
    func isAddExpenseSourceItem(indexPath: IndexPath) -> Bool {
        return indexPath.row == expenseSourceViewModels.count
    }
    
    func expenseSourceViewModel(at indexPath: IndexPath) -> ExpenseSourceViewModel? {
        return expenseSourceViewModels[safe: indexPath.row]
    }
    
    func expenseCategoryViewModel(at indexPath: IndexPath) -> ExpenseCategoryViewModel? {
        return expenseCategoryViewModels()[safe: indexPath.row]
    }
    
    func activeViewModel(at indexPath: IndexPath, basketType: BasketType) -> ActiveViewModel? {
        return activeViewModels(by: basketType)[safe: indexPath.row]
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
    
    func set(selecting: Bool) {
        self.selecting = selecting        
        if !selecting {
            resetTransactionables()
        }
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
