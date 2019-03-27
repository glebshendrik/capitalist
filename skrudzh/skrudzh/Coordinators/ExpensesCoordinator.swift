//
//  ExpensesCoordinator.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 07/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class ExpensesCoordinator : ExpensesCoordinatorProtocol {
    private let expensesService: ExpensesServiceProtocol
    
    init(expensesService: ExpensesServiceProtocol) {
        self.expensesService = expensesService
    }
    
    func create(with creationForm: ExpenseCreationForm) -> Promise<Expense> {
        return expensesService.create(with: creationForm)
    }
    
    func update(with updatingForm: ExpenseUpdatingForm) -> Promise<Void> {
        return expensesService.update(with: updatingForm)
    }
    
    func destroy(by id: Int) -> Promise<Void> {
        return expensesService.destroy(by: id)
    }
}