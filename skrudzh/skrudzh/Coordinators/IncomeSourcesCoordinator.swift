//
//  IncomeSourcesCoordinator.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 12/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class IncomeSourcesCoordinator : IncomeSourcesCoordinatorProtocol {
    private let userSessionManager: UserSessionManagerProtocol
    private let incomeSourcesService: IncomeSourcesServiceProtocol
    
    init(userSessionManager: UserSessionManagerProtocol,
         incomeSourcesService: IncomeSourcesServiceProtocol) {
        
        self.userSessionManager = userSessionManager
        self.incomeSourcesService = incomeSourcesService
    }
    
    func create(with creationForm: IncomeSourceCreationForm) -> Promise<IncomeSource> {
        return incomeSourcesService.create(with: creationForm)
    }
    
    func show(by id: Int) -> Promise<IncomeSource> {
        return incomeSourcesService.show(by: id)
    }
    
    func index() -> Promise<[IncomeSource]> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return incomeSourcesService.index(for: currentUserId)
    }
    
    func update(with updatingForm: IncomeSourceUpdatingForm) -> Promise<Void> {
        return incomeSourcesService.update(with: updatingForm)
    }
    
    func updatePosition(with updatingForm: IncomeSourcePositionUpdatingForm) -> Promise<Void> {
        return incomeSourcesService.updatePosition(with: updatingForm)
    }
    
    func destroy(by id: Int) -> Promise<Void> {
        return incomeSourcesService.destroy(by: id)
    }
}
