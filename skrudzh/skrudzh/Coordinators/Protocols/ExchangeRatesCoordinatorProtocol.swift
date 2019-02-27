//
//  ExchangeRatesCoordinatorProtocol.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 27/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

protocol ExchangeRatesCoordinatorProtocol {
    func show(from fromCurrency: String, to toCurrency: String) -> Promise<ExchangeRate>
}
