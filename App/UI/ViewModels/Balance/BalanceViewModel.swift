//
//  BalanceViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 10/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum BalanceCategory {
    case expenseSources
    case actives
}

class BalanceViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    private let expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol
    private let activesCoordinator: ActivesCoordinatorProtocol
    
    public private(set) var budgetViewModel: BudgetViewModel? = nil
    private var expenseSourceViewModels: [ExpenseSourceViewModel] = []
    private var activeViewModels: [ActiveViewModel] = []
    
    var numberOfExpenseSources: Int {
        return expenseSourceViewModels.count
    }
    
    var numberOfActives: Int {
        return activeViewModels.count
    }
    
    var selectedBalanceCategory: BalanceCategory = .expenseSources
    
    init(accountCoordinator: AccountCoordinatorProtocol,
         expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol,
         activesCoordinator: ActivesCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
        self.activesCoordinator = activesCoordinator
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
                    expenseSourcesCoordinator.index(currency: nil)
                }.get { expenseSources in
                    self.expenseSourceViewModels = expenseSources
                        .map { ExpenseSourceViewModel(expenseSource: $0)}                        
                }.asVoid()
    }
    
    func loadActives() -> Promise<Void> {
        return  firstly {
                    activesCoordinator.indexUserActives()
                }.get { actives in
                    self.activeViewModels = actives
                        .map { ActiveViewModel(active: $0)}
                }.asVoid()
    }
    
    func expenseSourceViewModel(at indexPath: IndexPath) -> ExpenseSourceViewModel? {
        return expenseSourceViewModels[safe: indexPath.row]
    }
    
    func activeViewModel(at indexPath: IndexPath) -> ActiveViewModel? {        
        return activeViewModels[safe: indexPath.row]
    }
}
