//
//  ExchangeRatesCoordinatorProtocol.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 27/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol ExchangeRatesCoordinatorProtocol {
    func index() -> Promise<[ExchangeRate]>
    func show(from fromCurrency: String, to toCurrency: String) -> Promise<ExchangeRate>
}
