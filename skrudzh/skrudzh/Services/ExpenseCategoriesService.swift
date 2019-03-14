//
//  ExpenseCategoriesService.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 14/01/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class ExpenseCategoriesService : Service, ExpenseCategoriesServiceProtocol {
    func create(with creationForm: ExpenseCategoryCreationForm) -> Promise<ExpenseCategory> {
        return request(APIResource.createExpenseCategory(form: creationForm))
    }
    
    func show(by id: Int) -> Promise<ExpenseCategory> {
        return request(APIResource.showExpenseCategory(id: id))
    }
    
    func index(for basketId: Int) -> Promise<[ExpenseCategory]> {
        return requestCollection(APIResource.indexExpenseCategories(basketId: basketId))
    }
    
    func update(with updatingForm: ExpenseCategoryUpdatingForm) -> Promise<Void> {
        return request(APIResource.updateExpenseCategory(form: updatingForm))
    }
    
    func updatePosition(with updatingForm: ExpenseCategoryPositionUpdatingForm) -> Promise<Void> {
        return request(APIResource.updateExpenseCategoryPosition(form: updatingForm))
    }
    
    func destroy(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return request(APIResource.destroyExpenseCategory(id: id, deleteTransactions: deleteTransactions))
    }
}
