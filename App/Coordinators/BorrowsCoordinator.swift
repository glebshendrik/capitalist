//
//  BorrowsCoordinator.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class BorrowsCoordinator : BorrowsCoordinatorProtocol {
    private let userSessionManager: UserSessionManagerProtocol
    private let borrowsService: BorrowsServiceProtocol
    
    init(userSessionManager: UserSessionManagerProtocol,
         borrowsService: BorrowsServiceProtocol) {
        
        self.userSessionManager = userSessionManager
        self.borrowsService = borrowsService
    }
    
    func indexDebts() -> Promise<[Borrow]> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return borrowsService.indexDebts(for: currentUserId)
    }
    
    func indexLoans() -> Promise<[Borrow]> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return borrowsService.indexLoans(for: currentUserId)
    }
    
    func createDebt(with creationForm: BorrowCreationForm) -> Promise<Borrow> {
        return borrowsService.createDebt(with: creationForm)
    }
    
    func createLoan(with creationForm: BorrowCreationForm) -> Promise<Borrow> {
        return borrowsService.createLoan(with: creationForm)
    }
    
    func showDebt(by id: Int) -> Promise<Borrow> {
        return borrowsService.showDebt(by: id)
    }
    
    func showLoan(by id: Int) -> Promise<Borrow> {
        return borrowsService.showLoan(by: id)
    }
    
    func updateDebt(with updatingForm: BorrowUpdatingForm) -> Promise<Void> {
        return borrowsService.updateDebt(with: updatingForm)
    }
    
    func updateLoan(with updatingForm: BorrowUpdatingForm) -> Promise<Void> {
        return borrowsService.updateLoan(with: updatingForm)
    }
    
    func destroyDebt(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return borrowsService.destroyDebt(by: id, deleteTransactions: deleteTransactions)
    }
    
    func destroyLoan(by id: Int, deleteTransactions: Bool) -> Promise<Void> {        
        return borrowsService.destroyLoan(by: id, deleteTransactions: deleteTransactions)
    }
}
