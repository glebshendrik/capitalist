//
//  ExpenseCategoriesCoordinator.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 14/01/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class ExpenseCategoriesCoordinator : ExpenseCategoriesCoordinatorProtocol {
    private let userSessionManager: UserSessionManagerProtocol
    private let expenseCategoriesService: ExpenseCategoriesServiceProtocol
    
    init(userSessionManager: UserSessionManagerProtocol,
         expenseCategoriesService: ExpenseCategoriesServiceProtocol) {
        self.userSessionManager = userSessionManager
        self.expenseCategoriesService = expenseCategoriesService
    }
    
    func create(with creationForm: ExpenseCategoryCreationForm) -> Promise<ExpenseCategory> {
        return expenseCategoriesService.create(with: creationForm)
    }
    
    func show(by id: Int) -> Promise<ExpenseCategory> {
        return expenseCategoriesService.show(by: id)
    }
    
    func first(for basketType: BasketType, noBorrows: Bool) -> Promise<ExpenseCategory?> {
        return  firstly {
                    index(for: basketType, noBorrows: noBorrows)
                }.map { expenseCategories in
                    expenseCategories.first
                }
    }
    
    func firstBorrow(for basketType: BasketType, currency: String) -> Promise<ExpenseCategory> {
        guard let currentSession = userSessionManager.currentSession else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        
        return expenseCategoriesService.firstBorrow(for: currentSession.basketId(basketType: basketType), currency: currency)
    }
    
    func index(for basketType: BasketType, noBorrows: Bool) -> Promise<[ExpenseCategory]> {
        
        guard let currentSession = userSessionManager.currentSession else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        
        return expenseCategoriesService.indexExpenseCategories(for: currentSession.basketId(basketType: basketType), noBorrows: noBorrows)
    }
    
    func index(noBorrows: Bool) -> Promise<[ExpenseCategory]> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return expenseCategoriesService.indexUserExpenseCategories(for: currentUserId, noBorrows: noBorrows)
    }
    
    func update(with updatingForm: ExpenseCategoryUpdatingForm) -> Promise<Void> {
        return expenseCategoriesService.update(with: updatingForm)
    }
    
    func updatePosition(with updatingForm: ExpenseCategoryPositionUpdatingForm) -> Promise<Void> {
        return expenseCategoriesService.updatePosition(with: updatingForm)
    }
    
    func destroy(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return expenseCategoriesService.destroy(by: id, deleteTransactions: deleteTransactions)
    }
}
