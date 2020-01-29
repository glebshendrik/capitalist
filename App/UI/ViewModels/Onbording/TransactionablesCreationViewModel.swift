//
//  TransactionablesCreationViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21.01.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class TransactionablesCreationViewModel {
    private let transactionableExamplesCoordinator: TransactionableExamplesCoordinatorProtocol
    private let incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol
    private let expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol
    private let expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol
    private let activesCoordinator: ActivesCoordinatorProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    private let settingsCoordinator: SettingsCoordinatorProtocol
    
    private var currentUser: User? = nil
    private var examples: [TransactionableExampleViewModel] = [] {
        didSet {
            examplesHash = examples.reduce(into: [String: TransactionableExampleViewModel]()) { $0[$1.name] = $1 }
        }
    }
    private var examplesHash: [String: TransactionableExampleViewModel] = [:]
    
    private var transactionables: [Transactionable] = [] {
        didSet {
            transactionablesHash = transactionables.reduce(into: [String: Transactionable]()) { $0[$1.name] = $1 }
        }
    }
    private var transactionablesHash: [String: Transactionable] = [:]
    
    public private(set) var transactionableType: TransactionableType = .expenseSource
    
    var basketType: BasketType? {
        return transactionableType == .expenseCategory ? .joy : nil
    }
    
    var stepTitle: String {
        switch transactionableType {
        case .expenseSource:
            return "НАЧАЛО РАБОТЫ"
        case .incomeSource:
            return "ЕЩЕ НЕМНОГО"
        case .expenseCategory:
            return "ПОЧТИ ВСЕ"
        default:
            return ""
        }
    }
    
    var title: String {
        switch transactionableType {
        case .expenseSource:
            return "Выберите валюту и кошельки"
        case .incomeSource:
            return "Выберите ваши источники дохода"
        case .expenseCategory:
            return "Выберите ваши категории расходов"
        default:
            return ""
        }
    }
    
    var subtitle: String {
        return "Добавить свой вариант вы сможете на главном экране приложения, нажав на + в конце списка"
    }
    
    var currencySelectorHidden: Bool {
        return transactionableType != .expenseSource
    }
    
    var backButtonHidden: Bool {
        return transactionableType == .expenseSource
    }
    
    var user: User? {
        return currentUser
    }
    
    var currencyName: String? {
        return user?.currency.translatedName
    }
    
    var currencySymbol: String? {
        return user?.currency.symbol
    }
    
    var numberOfExamples: Int {
        return examples.count
    }
    
    var numberOfTransactionables: Int {
        return transactionables.count
    }
    
    init(transactionableExamplesCoordinator: TransactionableExamplesCoordinatorProtocol,
         incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol,
         expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol,
         expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol,
         activesCoordinator: ActivesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         settingsCoordinator: SettingsCoordinatorProtocol) {
        
        self.transactionableExamplesCoordinator = transactionableExamplesCoordinator
        self.incomeSourcesCoordinator = incomeSourcesCoordinator
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
        self.expenseCategoriesCoordinator = expenseCategoriesCoordinator
        self.activesCoordinator = activesCoordinator
        self.accountCoordinator = accountCoordinator
        self.settingsCoordinator = settingsCoordinator
    }
    
    func set(transactionableType: TransactionableType) {
        self.transactionableType = transactionableType
    }
    
    func loadData() -> Promise<Void> {
        return  firstly {
                    onboardUser()
                }.then {
                    when(fulfilled: self.loadUser(), self.loadCollectionsData())
                }        
    }
    
    func onboardUser() -> Promise<Void> {
        guard transactionableType == .incomeSource else { return Promise.value(()) }
        return accountCoordinator.onboardCurrentUser()
    }
        
    func loadCollectionsData() -> Promise<Void> {
        return  firstly {
                    when(fulfilled: loadTransactionables(), loadExamples())
                }.get { transactionables, examples in
                    self.transactionables = transactionables
                    self.examples = examples
                    self.updateSelectedExamples()
                }.asVoid()
    }
    
    func update(currency: Currency) -> Promise<Void> {
        let form = UserSettingsUpdatingForm(userId: accountCoordinator.currentSession?.userId,
                                            currency: currency.code,
                                            defaultPeriod: nil)
        return update(settings: form)
    }
    
    func exampleViewModel(by indexPath: IndexPath) -> TransactionableExampleViewModel? {
        return examples.item(at: indexPath.row)
    }
    
    func transactionable(by name: String) -> Transactionable? {
        return transactionablesHash[name]
    }
    
    func nextStepTransactionableType() -> TransactionableType? {
        switch transactionableType {
        case .expenseSource:
            return .incomeSource
        case .incomeSource:
            return .expenseCategory
        default:
            return nil
        }
    }
    
    func previousStepTransactionableType() -> TransactionableType? {
        switch transactionableType {
        case .expenseCategory:
            return .incomeSource
        case .incomeSource:
            return .expenseSource
        default:
            return nil
        }
    }
    
    private func updateSelectedExamples() {
        for example in examples {
            example.selected = false
        }
        
        for transactionable in transactionables {
            examplesHash[transactionable.name]?.selected = true
        }
    }
    
    private func loadTransactionables() -> Promise<[Transactionable]> {
        switch transactionableType {
        case .incomeSource:
            return loadIncomeSources()
        case .expenseSource:
            return loadExpenseSources()
        case .expenseCategory:
            return loadExpenseCategories()
        case .active:
            return loadActives(by: basketType)
        }
    }
    
    private func loadIncomeSources() -> Promise<[Transactionable]> {
        return  firstly {
                    incomeSourcesCoordinator.index(noBorrows: false)
                }.map { incomeSources in
                    incomeSources.map { IncomeSourceViewModel(incomeSource: $0)}
                }
    }
    
    private func loadExpenseSources() -> Promise<[Transactionable]> {
        return  firstly {
                    expenseSourcesCoordinator.index(currency: nil)
                }.map { expenseSources in
                    expenseSources.map { ExpenseSourceViewModel(expenseSource: $0)}
                }
    }
    
    private func loadExpenseCategories() -> Promise<[Transactionable]> {
        return  firstly {
                    expenseCategoriesCoordinator.index(for: .joy, noBorrows: false)
                }.map { expenseCategories in
                    expenseCategories.map { ExpenseCategoryViewModel(expenseCategory: $0) }
                }
    }
    
    private func loadActives(by basketType: BasketType?) -> Promise<[Transactionable]> {
        guard let basketType = basketType else { return Promise.value([]) }
         return firstly {
                    activesCoordinator.indexActives(for: basketType)
                }.map { actives in
                    actives.map { ActiveViewModel(active: $0)}
                }
    }
            
    private func loadExamples() -> Promise<[TransactionableExampleViewModel]> {
        return  firstly {
                    transactionableExamplesCoordinator.indexBy(transactionableType, basketType: basketType)
                }.map { examples in
                    examples.map { TransactionableExampleViewModel(example: $0) }
                }
    }
    
    private func update(settings: UserSettingsUpdatingForm) -> Promise<Void> {
        return  firstly {
                    settingsCoordinator.updateUserSettings(with: settings)
                }.then { _ in
                    return self.loadUser()
                }
    }
    
    private func loadUser() -> Promise<Void> {
        return  firstly {
                    accountCoordinator.loadCurrentUser()
                }.get { user in
                    self.currentUser = user
                }.asVoid()
    }
}
