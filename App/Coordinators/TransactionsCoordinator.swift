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
    
    func index(fromGotAt: Date?,
               toGotAt: Date?) -> Promise<[Transaction]> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return transactionsService.index(for: currentUserId,
                                         type: nil,
                                         transactionableId: nil,
                                         transactionableType: nil,
                                         creditId: nil,
                                         borrowId: nil,
                                         borrowType: nil,
                                         count: nil,
                                         lastGotAt: nil,
                                         fromGotAt: fromGotAt,
                                         toGotAt: toGotAt)
    }
    
    func index(transactionableId: Int?,
               transactionableType: TransactionableType?,
               creditId: Int?,
               borrowId: Int?,
               borrowType: BorrowType?,
               count: Int?,
               lastGotAt: Date?) -> Promise<[Transaction]> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return transactionsService.index(for: currentUserId,
                                         type: nil,
                                         transactionableId: transactionableId,
                                         transactionableType: transactionableType,
                                         creditId: creditId,
                                         borrowId: borrowId,
                                         borrowType: borrowType,
                                         count: count,
                                         lastGotAt: lastGotAt,
                                         fromGotAt: nil,
                                         toGotAt: nil)
    }
    
    func index(by type: TransactionType) -> Promise<[Transaction]> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return transactionsService.index(for: currentUserId,
                                         type: type,
                                         transactionableId: nil,
                                         transactionableType: nil,
                                         creditId: nil,
                                         borrowId: nil,
                                         borrowType: nil,
                                         count: nil,
                                         lastGotAt: nil,
                                         fromGotAt: nil,
                                         toGotAt: nil)
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
    
    func duplicate(by id: Int) -> Promise<Void> {
        return transactionsService.duplicate(by: id)
    }
}
