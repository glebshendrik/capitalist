//
//  ExpenseSourcesViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 14/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class ExpenseSourcesViewModel {
    private let expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol
    private var expenseSourceViewModels: [ExpenseSourceViewModel] = []
    
    var numberOfExpenseSources: Int {
        return expenseSourceViewModels.count
    }
    
    var noDebts: Bool = false
    var skipExpenseSourceId: Int? = nil
    var currency: String? = nil
    var accountType: AccountType? = nil
    
    init(expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol) {
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
    }
    
    func loadExpenseSources() -> Promise<Void> {
        return  firstly {
                    expenseSourcesCoordinator.index(noDebts: noDebts,
                                                    accountType: accountType,
                                                    currency: currency)
                }.get { expenseSources in
                    self.expenseSourceViewModels = expenseSources
                        .map { ExpenseSourceViewModel(expenseSource: $0)}
                        .filter { $0.canStartTransaction && $0.id != self.skipExpenseSourceId }
                }.asVoid()
    }
    
    func expenseSourceViewModel(at indexPath: IndexPath) -> ExpenseSourceViewModel? {
        return expenseSourceViewModels.item(at: indexPath.row)
    }
}
