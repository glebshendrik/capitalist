//
//  ExchangeRatesService.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class ExchangeRatesService : Service, ExchangeRatesServiceProtocol {
    func show(from fromCurrency: String, to toCurrency: String) -> Promise<ExchangeRate> {
        return request(APIResource.findExchangeRate(from: fromCurrency, to: toCurrency))
    }
}
