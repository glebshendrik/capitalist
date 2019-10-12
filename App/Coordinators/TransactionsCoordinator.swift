//
//  TransactionsCoordinator.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class TransactionsCoordinator : TransactionsCoordinatorProtocol {
    private let userSessionManager: UserSessionManagerProtocol
    private let transactionsService: TransactionsServiceProtocol
    
    init(userSessionManager: UserSessionManagerProtocol,
         transactionsService: TransactionsServiceProtocol) {
        self.userSessionManager = userSessionManager
        self.transactionsService = transactionsService
    }
    
    func index() -> Promise<[Transaction]> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return transactionsService.index(for: currentUserId, transactionType: nil)
    }
    
    func index(by transactionType: TransactionType) -> Promise<[Transaction]> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return transactionsService.index(for: currentUserId, transactionType: transactionType)
    }
    
    func create(with creationForm: TransactionCreationForm) -> Promise<Transaction> {
        return transactionsService.create(with: creationForm)
    }
    
    func show(by id: Int) -> Promise<Transaction> {
        return transactionsService.show(by: id)
    }
    
    func update(with updatingForm: TransactionUpdatingForm) -> Promise<Void> {
        return transactionsService.update(with: updatingForm)
    }
    
    func destroy(by id: Int) -> Promise<Void> {
        return transactionsService.destroy(by: id)
    }
}
