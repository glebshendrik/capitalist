//
//  ExpenseCategoriesViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 14/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class ExpenseCategoriesViewModel {
    private let expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol
    private var expenseCategoryViewModels: [ExpenseCategoryViewModel] = []
    private var sections: [ItemsSection] {
        return isAddingAllowed ? [.adding, .items] : [.items]
    }
    
    var isAddingAllowed: Bool = true
    var isUpdatingData: Bool = false
    
    var numberOfSections: Int {
        return sections.count
    }
    
    var numberOfItems: Int {
        return expenseCategoryViewModels.count
    }
    
    init(expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol) {
        self.expenseCategoriesCoordinator = expenseCategoriesCoordinator
    }
    
    func loadData() -> Promise<Void> {
        return loadExpenseCategories()
    }
    
    func loadExpenseCategories() -> Promise<Void> {
        return  firstly {
                    expenseCategoriesCoordinator.index(noBorrows: false)
                }.get { expenseCategories in
                    self.expenseCategoryViewModels = expenseCategories.map { ExpenseCategoryViewModel(expenseCategory: $0)}
                }.asVoid()
    }
    
    func removeExpenseCategory(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return expenseCategoriesCoordinator.destroy(by: id, deleteTransactions: deleteTransactions)
    }
        
    func expenseCategoryViewModel(at indexPath: IndexPath) -> ExpenseCategoryViewModel? {
        return expenseCategoryViewModels[safe: indexPath.row]
    }
    
    func section(at index: Int) -> ItemsSection? {
        return sections[safe: index]
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        guard let section = self.section(at: section) else { return 0 }
        switch section {
        case .adding:
            return 1
        case .items:
            return numberOfItems
        }
    }
}
