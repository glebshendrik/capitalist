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
    
    var skipExpenseSourceId: Int? = nil
    var currency: String? = nil
    
    init(expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol) {
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
    }
    
    func loadExpenseSources() -> Promise<Void> {
        return  firstly {
                    expenseSourcesCoordinator.index(currency: currency)
                }.get { expenseSources in
                    self.expenseSourceViewModels = expenseSources
                        .map { ExpenseSourceViewModel(expenseSource: $0)}
                        .filter { $0.isTransactionSource && $0.id != self.skipExpenseSourceId }
                }.asVoid()
    }
    
    func expenseSourceViewModel(at indexPath: IndexPath) -> ExpenseSourceViewModel? {
        return expenseSourceViewModels.item(at: indexPath.row)
    }
}
