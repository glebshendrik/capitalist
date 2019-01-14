//
//  ExpenseCategoriesCoordinator.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 14/01/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class ExpenseCategoriesCoordinator : ExpenseCategoriesCoordinatorProtocol {
    private let expenseCategoriesService: ExpenseCategoriesServiceProtocol
    
    init(expenseCategoriesService: ExpenseCategoriesServiceProtocol) {
        self.expenseCategoriesService = expenseCategoriesService
    }
    
    func create(with creationForm: ExpenseCategoryCreationForm) -> Promise<ExpenseCategory> {
        return expenseCategoriesService.create(with: creationForm)
    }
    
    func show(by id: Int) -> Promise<ExpenseCategory> {
        return expenseCategoriesService.show(by: id)
    }
    
    func index(for basketId: Int) -> Promise<[ExpenseCategory]> {
        return expenseCategoriesService.index(for: basketId)
    }
    
    func update(with updatingForm: ExpenseCategoryUpdatingForm) -> Promise<Void> {
        return expenseCategoriesService.update(with: updatingForm)
    }
    
    func destroy(by id: Int) -> Promise<Void> {
        return expenseCategoriesService.destroy(by: id)
    }
}
