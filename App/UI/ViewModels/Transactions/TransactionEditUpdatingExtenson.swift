//
//  TransactionEditUpdatingExtenson.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

extension TransactionEditViewModel {
    func didSetSource(_ oldValue: Transactionable?) {
        if source?.currency.code != oldValue?.currency.code {
            amount = nil
            amountConverted = nil
        }
    }
    
    func didSetDestination(_ oldValue: Transactionable?) {
        if destination?.currency.code != oldValue?.currency.code {
            convertedAmount = nil
            convertedAmountConverted = nil
        }
    }
    
    func didSetAmount() {
        if !needCurrencyExchange {
            convertedAmount = amount
        }
        updateConvertedAmountConverted()
    }
    
    func didSetConvertedAmount() {
        updateAmountConverted()
    }
    
    func didSetExchangeRate() {
        updateAmountConverted()
        updateConvertedAmountConverted()
    }
}

extension TransactionEditViewModel {
    func updateAmountConverted() {
        amountConverted = convert(amount: convertedAmount, isForwardConversion: false)
    }
    
    func updateConvertedAmountConverted() {
        convertedAmountConverted = convert(amount: amount, isForwardConversion: true)
    }
    
    func convert(amount: String?, isForwardConversion: Bool = true) -> String? {
        guard   let currency = sourceCurrency,
                let convertedCurrency = destinationCurrency,
            let amountCents = amount?.intMoney(with: isForwardConversion ? currency : convertedCurrency) else { return nil }
        
        let convertedAmountCents = currencyConverter.convert(cents: amountCents,
                                                             fromCurrency: currency,
                                                             toCurrency: convertedCurrency,
                                                             exchangeRate: Double(exchangeRate),
                                                             forward: isForwardConversion)
            
        return convertedAmountCents.moneyDecimalString(with: isForwardConversion ? convertedCurrency : currency)
    }
}
