//
//  ExchangeRatesServiceProtocol.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

protocol ExchangeRatesServiceProtocol {
    func show(from fromCurrency: String, to toCurrency: String) -> Promise<ExchangeRate>
}
