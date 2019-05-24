//
//  CurrencyConverterProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 04/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

protocol CurrencyConverterProtocol {
    func convert(cents: Int, fromCurrency: Currency, toCurrency: Currency, exchangeRate: Double, forward: Bool) -> NSDecimalNumber
}
