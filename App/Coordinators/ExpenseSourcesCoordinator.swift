//
//  ExpenseSourcesCoordinator.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 25/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class ExpenseSourcesCoordinator : ExpenseSourcesCoordinatorProtocol {
    private let userSessionManager: UserSessionManagerProtocol
    private let expenseSourcesService: ExpenseSourcesServiceProtocol
    
    init(userSessionManager: UserSessionManagerProtocol,
         expenseSourcesService: ExpenseSourcesServiceProtocol) {
        
        self.userSessionManager = userSessionManager
        self.expenseSourcesService = expenseSourcesService
    }
    
    func create(with creationForm: ExpenseSourceCreationForm) -> Promise<ExpenseSource> {
        return expenseSourcesService.create(with: creationForm)
    }
    
    func show(by id: Int) -> Promise<ExpenseSource> {
        return expenseSourcesService.show(by: id)
    }
    
    func index(noDebts: Bool) -> Promise<[ExpenseSource]> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return expenseSourcesService.index(for: currentUserId, noDebts: noDebts)
    }
    
    func update(with updatingForm: ExpenseSourceUpdatingForm) -> Promise<Void> {
        return expenseSourcesService.update(with: updatingForm)
    }
    
    func updatePosition(with updatingForm: ExpenseSourcePositionUpdatingForm) -> Promise<Void> {
        return expenseSourcesService.updatePosition(with: updatingForm)
    }
    
    func destroy(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return expenseSourcesService.destroy(by: id, deleteTransactions: deleteTransactions)
    }
}
