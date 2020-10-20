//
//  ExchangeRatesService.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 28/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class ExchangeRatesService : Service, ExchangeRatesServiceProtocol {
    func index(for userId: Int) -> Promise<[ExchangeRate]> {
        return requestCollection(.indexExchangeRates(userId: userId))
    }
    
    func show(from fromCurrency: String, to toCurrency: String) -> Promise<ExchangeRate> {
        return request(APIRoute.findExchangeRate(from: fromCurrency, to: toCurrency))
    }
}
