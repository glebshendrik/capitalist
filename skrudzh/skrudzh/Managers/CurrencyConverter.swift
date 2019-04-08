//
//  CurrencyConverter.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 04/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation

class CurrencyConverter : CurrencyConverterProtocol {
    
    func convert(cents: Int, fromCurrency: Currency, toCurrency: Currency, exchangeRate: Double, forward: Bool) -> NSDecimalNumber {
        
        
        let centsNumber = NSDecimalNumber(integerLiteral: cents)
        let fromCurrencySubunitToUnit = NSDecimalNumber(integerLiteral: fromCurrency.subunitToUnit)
        let toCurrencySubunitToUnit = NSDecimalNumber(integerLiteral: toCurrency.subunitToUnit)
        let exchangeRateNumber = NSDecimalNumber(floatLiteral: exchangeRate)
        
        return forward
            ? convertForward(cents: centsNumber,
                             exchangeRate: exchangeRateNumber,
                             fromCurrencySubunitToUnit: fromCurrencySubunitToUnit,
                             toCurrencySubunitToUnit: toCurrencySubunitToUnit)
            : convertBackward(cents: centsNumber,
                              exchangeRate: exchangeRateNumber,
                              fromCurrencySubunitToUnit: fromCurrencySubunitToUnit,
                              toCurrencySubunitToUnit: toCurrencySubunitToUnit)        
    }
    
    private func convertForward(cents: NSDecimalNumber, exchangeRate: NSDecimalNumber, fromCurrencySubunitToUnit: NSDecimalNumber, toCurrencySubunitToUnit: NSDecimalNumber) -> NSDecimalNumber {
        return cents
            .multiplying(by: toCurrencySubunitToUnit)
            .multiplying(by: exchangeRate)
            .dividing(by: fromCurrencySubunitToUnit)
    }
    
    private func convertBackward(cents: NSDecimalNumber, exchangeRate: NSDecimalNumber, fromCurrencySubunitToUnit: NSDecimalNumber, toCurrencySubunitToUnit: NSDecimalNumber) -> NSDecimalNumber {
        return cents
            .dividing(by: exchangeRate
                .multiplying(by: toCurrencySubunitToUnit)
                .dividing(by: fromCurrencySubunitToUnit))
    }
}
