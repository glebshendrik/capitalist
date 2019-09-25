//
//  CreditsCoordinator.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class CreditsCoordinator : CreditsCoordinatorProtocol {
    private let userSessionManager: UserSessionManagerProtocol
    private let creditsService: CreditsServiceProtocol
    
    init(userSessionManager: UserSessionManagerProtocol,
         creditsService: CreditsServiceProtocol) {        
        self.userSessionManager = userSessionManager
        self.creditsService = creditsService
    }
    
    func indexCredits() -> Promise<[Credit]> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return creditsService.indexCredits(for: currentUserId)
    }
        
    func createCredit(with creationForm: CreditCreationForm) -> Promise<Credit> {
        return creditsService.createCredit(with: creationForm)
    }
    
    func showCredit(by id: Int) -> Promise<Credit> {
        return creditsService.showCredit(by: id)
    }
    
    func updateCredit(with updatingForm: CreditUpdatingForm) -> Promise<Void> {
        return creditsService.updateCredit(with: updatingForm)
    }
    
    func destroyCredit(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return creditsService.destroyCredit(by: id, deleteTransactions: deleteTransactions)
    }
}
