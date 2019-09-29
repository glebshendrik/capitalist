//
//  HistoryTransactionsCoordinator.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class HistoryTransactionsCoordinator : HistoryTransactionsCoordinatorProtocol {
    private let userSessionManager: UserSessionManagerProtocol
    private let historyTransactionsService: HistoryTransactionsServiceProtocol
    private let incomesCoordinator: IncomesCoordinatorProtocol
    private let fundsMovesCoordinator: FundsMovesCoordinatorProtocol
    private let expensesCoordinator: ExpensesCoordinatorProtocol
    
    init(userSessionManager: UserSessionManagerProtocol,
         historyTransactionsService: HistoryTransactionsServiceProtocol,
         incomesCoordinator: IncomesCoordinatorProtocol,
         fundsMovesCoordinator: FundsMovesCoordinatorProtocol,
         expensesCoordinator: ExpensesCoordinatorProtocol) {
        self.userSessionManager = userSessionManager
        self.historyTransactionsService = historyTransactionsService
        self.incomesCoordinator = incomesCoordinator
        self.fundsMovesCoordinator = fundsMovesCoordinator
        self.expensesCoordinator = expensesCoordinator
    }
    
    func index() -> Promise<[HistoryTransaction]> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return historyTransactionsService.index(for: currentUserId)
    }
    
    func destroy(historyTransaction: HistoryTransaction) -> Promise<Void> {
        switch historyTransaction.transactionableType {
        case .income:
            return incomesCoordinator.destroy(by: historyTransaction.transactionableId)
        case .fundsMove:
            return fundsMovesCoordinator.destroy(by: historyTransaction.transactionableId)
        case .expense:
            return expensesCoordinator.destroy(by: historyTransaction.transactionableId)
        }
    }
}
