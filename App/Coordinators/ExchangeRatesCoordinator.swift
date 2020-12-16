//
//  ExchangeRatesCoordinator.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class ExchangeRatesCoordinator : ExchangeRatesCoordinatorProtocol {
    private let userSessionManager: UserSessionManagerProtocol
    private let exchangeRatesService: ExchangeRatesServiceProtocol
    
    init(userSessionManager: UserSessionManagerProtocol,
         exchangeRatesService: ExchangeRatesServiceProtocol) {
        self.userSessionManager = userSessionManager
        self.exchangeRatesService = exchangeRatesService        
    }
    
    func index() -> Promise<[ExchangeRate]> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return exchangeRatesService.index(for: currentUserId)
    }
    
    func show(from fromCurrency: String, to toCurrency: String) -> Promise<ExchangeRate> {
        return exchangeRatesService.show(from: fromCurrency, to: toCurrency)
    }
}
