//
//  BasketsCoordinator.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 14/01/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class BasketsCoordinator : BasketsCoordinatorProtocol {
    private let userSessionManager: UserSessionManagerProtocol
    private let basketsService: BasketsServiceProtocol
    
    init(userSessionManager: UserSessionManagerProtocol,
         basketsService: BasketsServiceProtocol) {
        
        self.userSessionManager = userSessionManager
        self.basketsService = basketsService
    }
    
    func show(by id: Int) -> Promise<Basket> {
        return basketsService.show(by: id)
    }
    
    func index() -> Promise<[Basket]> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return basketsService.index(for: currentUserId)
    }
    
    
}
