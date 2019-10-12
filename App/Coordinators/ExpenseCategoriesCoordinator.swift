//
//  ExpenseCategoriesCoordinator.swift
//  Three Baskets
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
    
    func index(for basketType: BasketType) -> Promise<[ExpenseCategory]> {
        
        guard let currentSession = userSessionManager.currentSession else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        
        func basketId() -> Int {
            switch basketType {
            case .joy:
                return currentSession.joyBasketId
            case .risk:
                return currentSession.riskBasketId
            case .safe:
                return currentSession.safeBasketId
            }
        }
        
        return expenseCategoriesService.indexExpenseCategories(for: basketId())
    }
    
    func index() -> Promise<[ExpenseCategory]> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return expenseCategoriesService.indexUserExpenseCategories(for: currentUserId)
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
