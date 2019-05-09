//
//  ExpenseCategoriesViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 14/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class ExpenseCategoriesViewModel {
    private let expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol
    private var expenseCategoryViewModels: [ExpenseCategoryViewModel] = []
    
    var numberOfExpenseCategories: Int {
        return expenseCategoryViewModels.count
    }
    
    init(expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol) {
        self.expenseCategoriesCoordinator = expenseCategoriesCoordinator
    }
    
    func loadExpenseCategories() -> Promise<Void> {
        return  firstly {
            expenseCategoriesCoordinator.index(includedInBalance: false)
        }.get { expenseCategories in            
            self.expenseCategoryViewModels = expenseCategories.map { ExpenseCategoryViewModel(expenseCategory: $0)}
        }.asVoid()
    }
    
    func expenseCategoryViewModel(at indexPath: IndexPath) -> ExpenseCategoryViewModel? {
        return expenseCategoryViewModels.item(at: indexPath.row)
    }
}
