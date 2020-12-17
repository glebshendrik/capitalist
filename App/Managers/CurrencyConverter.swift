//
//  CurrencyConverter.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 04/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

struct Amount {
    var cents: Int
    var currency: Currency
}

class CurrencyConverter : CurrencyConverterProtocol {
    
    private let exchangeRatesCoordinator: ExchangeRatesCoordinatorProtocol
    
    init(exchangeRatesCoordinator: ExchangeRatesCoordinatorProtocol) {
        self.exchangeRatesCoordinator = exchangeRatesCoordinator
    }
    
    func summUp(amounts: [Amount], currency: Currency) -> Promise<NSDecimalNumber> {

//        let currencyCodes = amounts.map { $0.currency.code }.withoutDuplicates().filter { $0 != currency.code }
        
        return  firstly {
                    exchangeRatesHash()
                }.map { ratesHash in
                    amounts
                        .map { amount in
                            guard amount.currency.code != currency.code else {
                                return NSDecimalNumber(integerLiteral: amount.cents)
                            }
                            guard let exchangeRate = ratesHash[amount.currency.code] else { return 0 }
                                   
                            return self.convert(cents: amount.cents,
                                                fromCurrency: amount.currency,
                                                toCurrency: currency,
                                                exchangeRate: Double(exchangeRate),
                                                forward: true)
                        }.reduce(0, +)
                }
    }
    
    private func exchangeRatesHash() -> Promise<[String : Float]> {
        return  firstly {
                    exchangeRatesCoordinator.index()
//                    when(fulfilled: currencyCodes.map { loadExchangeRate(from: $0,
//                                                                         to: currencyCode)} )
                }.map { rates in
                    return rates.reduce(into: [String : Float]()) { (hash, rate) in hash[rate.from] = rate.rate }
                }
    }
    
    private func loadExchangeRate(from fromCurrencyCode: String, to toCurrencyCode: String) -> Promise<ExchangeRate> {
        return exchangeRatesCoordinator.show(from: fromCurrencyCode, to: toCurrencyCode)
    }
    
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
