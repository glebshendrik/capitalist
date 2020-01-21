//
//  ActivesCoordinator.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class ActivesCoordinator : ActivesCoordinatorProtocol {
    private let userSessionManager: UserSessionManagerProtocol
    private let activesService: ActivesServiceProtocol
    private let activeTypesService: ActiveTypesServiceProtocol
    
    init(userSessionManager: UserSessionManagerProtocol,
         activesService: ActivesServiceProtocol,
         activeTypesService: ActiveTypesServiceProtocol) {
        self.userSessionManager = userSessionManager
        self.activesService = activesService
        self.activeTypesService = activeTypesService
    }
    
    func indexActiveTypes() -> Promise<[ActiveType]> {
        return activeTypesService.indexActiveTypes()
    }
    
    func indexActives(for basketType: BasketType) -> Promise<[Active]> {
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
        return activesService.indexActives(for: basketId())
    }
        
    func indexUserActives() -> Promise<[Active]> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return activesService.indexUserActives(for: currentUserId)
    }
        
    func createActive(with creationForm: ActiveCreationForm) -> Promise<Active> {
        return activesService.createActive(with: creationForm)
    }
    
    func showActive(by id: Int) -> Promise<Active> {
        return activesService.showActive(by: id)
    }
    
    func updateActive(with updatingForm: ActiveUpdatingForm) -> Promise<Void> {
        return activesService.updateActive(with: updatingForm)
    }
    
    func updatePosition(with updatingForm: ActivePositionUpdatingForm) -> Promise<Void> {
        return activesService.updatePosition(with: updatingForm)
    }
    
    func destroyActive(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return activesService.destroyActive(by: id, deleteTransactions: deleteTransactions)
    }
}
