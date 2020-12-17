//
//  ExchangeRatesServiceProtocol.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 28/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol ExchangeRatesServiceProtocol {
    func index(for userId: Int) -> Promise<[ExchangeRate]>
    func show(from fromCurrency: String, to toCurrency: String) -> Promise<ExchangeRate>
}
