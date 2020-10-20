//
//  CurrencyConverterProtocol.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 04/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol CurrencyConverterProtocol {
    func summUp(amounts: [Amount], currency: Currency) -> Promise<NSDecimalNumber>
    func convert(cents: Int, fromCurrency: Currency, toCurrency: Currency, exchangeRate: Double, forward: Bool) -> NSDecimalNumber
}
