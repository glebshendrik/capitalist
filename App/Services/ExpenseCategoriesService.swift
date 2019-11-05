//
//  ExpenseCategoriesService.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 14/01/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class ExpenseCategoriesService : Service, ExpenseCategoriesServiceProtocol {
    func create(with creationForm: ExpenseCategoryCreationForm) -> Promise<ExpenseCategory> {
        return request(APIRoute.createExpenseCategory(form: creationForm))
    }
    
    func show(by id: Int) -> Promise<ExpenseCategory> {
        return request(APIRoute.showExpenseCategory(id: id))
    }
    
    func firstBorrow(for basketId: Int, currency: String) -> Promise<ExpenseCategory> {
        return request(APIRoute.firstBorrowExpenseCategory(basketId: basketId, currency: currency))
    }
    
    func indexExpenseCategories(for basketId: Int, noBorrows: Bool) -> Promise<[ExpenseCategory]> {
        return requestCollection(APIRoute.indexExpenseCategories(basketId: basketId, noBorrows: noBorrows))
    }
    
    func indexUserExpenseCategories(for userId: Int, noBorrows: Bool) -> Promise<[ExpenseCategory]> {
        return requestCollection(APIRoute.indexUserExpenseCategories(userId: userId, noBorrows: noBorrows))
    }
    
    func update(with updatingForm: ExpenseCategoryUpdatingForm) -> Promise<Void> {
        return request(APIRoute.updateExpenseCategory(form: updatingForm))
    }
    
    func updatePosition(with updatingForm: ExpenseCategoryPositionUpdatingForm) -> Promise<Void> {
        return request(APIRoute.updateExpenseCategoryPosition(form: updatingForm))
    }
    
    func destroy(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return request(APIRoute.destroyExpenseCategory(id: id, deleteTransactions: deleteTransactions))
    }
}
