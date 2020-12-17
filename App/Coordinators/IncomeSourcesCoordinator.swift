//
//  IncomeSourcesCoordinator.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 12/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
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
    
    func first(noBorrows: Bool) -> Promise<IncomeSource?> {
        return  firstly {
                    index(noBorrows: noBorrows)
                }.map { incomeSources in
                    incomeSources.first
                }
    }
    
    func firstBorrow(currency: String) -> Promise<IncomeSource> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return incomeSourcesService.firstBorrow(for: currentUserId, currency: currency)
    }
    
    func index(noBorrows: Bool) -> Promise<[IncomeSource]> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return incomeSourcesService.index(for: currentUserId, noBorrows: noBorrows)
    }
    
    func update(with updatingForm: IncomeSourceUpdatingForm) -> Promise<Void> {
        return incomeSourcesService.update(with: updatingForm)
    }
    
    func updatePosition(with updatingForm: IncomeSourcePositionUpdatingForm) -> Promise<Void> {
        return incomeSourcesService.updatePosition(with: updatingForm)
    }
    
    func destroy(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return incomeSourcesService.destroy(by: id, deleteTransactions: deleteTransactions)
    }
}
