//
//  TransactionEditViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 27/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class TransactionEditViewModel {
    private var exchangeRatesCoordinator: ExchangeRatesCoordinatorProtocol
    
    var startable: TransactionStartable? = nil
    var completable: TransactionCompletable? = nil
    
    var title: String? { return nil }
    var removeTitle: String? { return nil }
    var removeQuestion: String? { return nil }
    var startableTitle: String? { return nil }
    var completableTitle: String? { return nil }
    var startableAmountTitle: String? { return nil }
    var completableAmountTitle: String? { return nil }
    var amount: String? { return nil }
    var convertedAmount: String? { return nil }
    
    var isNew: Bool { return true }
    
    var startableIconURL: URL? {
        return startable?.iconURL
    }
    
    var startableIconDefaultImageName: String {
        return ""
    }
    
    var completableIconURL: URL? {
        return completable?.iconURL
    }
    
    var completableIconDefaultImageName: String {
        return ""
    }
    
    var startableName: String? {
        return startable?.name
    }
    
    var completableName: String? {
        return completable?.name
    }
    
    var startableAmount: String? {
        return startable?.amount
    }
    
    var completableAmount: String? {
        return completable?.amount
    }
    
    var startableCurrency: Currency? {
        return startable?.currency
    }
    
    var completableCurrency: Currency? {
        return completable?.currency
    }
    
    var startableCurrencyCode: String? {
        return startableCurrency?.code
    }
    
    var completableCurrencyCode: String? {
        return completableCurrency?.code
    }
    
    var needCurrencyExchange: Bool {
        return startableCurrency?.code != completableCurrency?.code
    }
    
    var exchangeRate: Float = 1.0
    
    init(exchangeRatesCoordinator: ExchangeRatesCoordinatorProtocol) {
        self.exchangeRatesCoordinator = exchangeRatesCoordinator
    }
    
    func loadExchangeRate() -> Promise<Void> {
        guard   needCurrencyExchange,
                let fromCurrencyCode = startableCurrencyCode,
                let toCurrencyCode = completableCurrencyCode else {
            return Promise.value(())
        }
        return  firstly {
                    exchangeRatesCoordinator.show(from: fromCurrencyCode, to: toCurrencyCode)
                }.done { exchangeRate in
                    self.exchangeRate = exchangeRate.rate
                }
    }
    
    func convert(amount: String?) -> String? {
        guard   let currency = startableCurrency,
                let convertedCurrency = completableCurrency,
                let amountCents = amount?.intMoney(with: currency) else { return nil }
        
        let convertedAmountCents = Int((Float(amountCents) * exchangeRate).rounded())
        return convertedAmountCents.moneyDecimalString(with: convertedCurrency)
    }
}
