//
//  HistoryTransactionsCoordinator.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 21/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class HistoryTransactionsCoordinator : HistoryTransactionsCoordinatorProtocol {
    let userSessionManager: UserSessionManagerProtocol
    let historyTransactionsService: HistoryTransactionsServiceProtocol
    
    init(userSessionManager: UserSessionManagerProtocol,
         historyTransactionsService: HistoryTransactionsServiceProtocol) {
        self.userSessionManager = userSessionManager
        self.historyTransactionsService = historyTransactionsService
    }
    
    func index() -> Promise<[HistoryTransaction]> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return historyTransactionsService.index(for: currentUserId)
    }
}
