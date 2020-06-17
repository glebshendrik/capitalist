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
    private let bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol
    
    init(userSessionManager: UserSessionManagerProtocol,
         expenseSourcesService: ExpenseSourcesServiceProtocol,
         bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol) {
        
        self.userSessionManager = userSessionManager
        self.expenseSourcesService = expenseSourcesService
        self.bankConnectionsCoordinator = bankConnectionsCoordinator
    }
    
    func create(with creationForm: ExpenseSourceCreationForm) -> Promise<ExpenseSource> {
        return expenseSourcesService.create(with: creationForm)
    }
    
    func show(by id: Int) -> Promise<ExpenseSource> {
        return  firstly {
                    expenseSourcesService.show(by: id)
                }.then { expenseSource in
                    self.syncedWithConnection(expenseSource: expenseSource)
                }
    }
    
    private func syncedWithConnection(expenseSource: ExpenseSource) -> Promise<ExpenseSource> {
        guard   let accountConnection = expenseSource.accountConnection,
                let connectionId = accountConnection.account.connection.id else {
            return Promise.value(expenseSource)
        }
        return  firstly {
                    bankConnectionsCoordinator.updateConnection(id: connectionId,
                                                                saltedgeId: accountConnection.account.connection.saltedgeId)
                }.then {
                    self.expenseSourcesService.show(by: expenseSource.id)
                }
    }
    
    func first() -> Promise<ExpenseSource?> {
        return  firstly {
                    index(currency: nil)
                }.map { expenseSources in
                    expenseSources.first
                }
    }
    
    func first(currency: String, isVirtual: Bool) -> Promise<ExpenseSource> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return expenseSourcesService.first(for: currentUserId, currency: currency, isVirtual: isVirtual)
    }
    
    func index(currency: String?) -> Promise<[ExpenseSource]> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return expenseSourcesService.index(for: currentUserId, currency: currency)
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
