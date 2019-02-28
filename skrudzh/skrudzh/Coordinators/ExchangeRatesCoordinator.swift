//
//  ExchangeRatesCoordinator.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class ExchangeRatesCoordinator : ExchangeRatesCoordinatorProtocol {
    private let exchangeRatesService: ExchangeRatesServiceProtocol
    
    init(exchangeRatesService: ExchangeRatesServiceProtocol) {
        self.exchangeRatesService = exchangeRatesService
    }
    
    func show(from fromCurrency: String, to toCurrency: String) -> Promise<ExchangeRate> {
        return exchangeRatesService.show(from: fromCurrency, to: toCurrency)
    }
}
