//
//  TransactionEditViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 27/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum TransactionError : Error {
    case transactionIsNotSpecified
}

class TransactionEditViewModel {
    private let exchangeRatesCoordinator: ExchangeRatesCoordinatorProtocol
    private let currencyConverter: CurrencyConverterProtocol
    
    var transactionableId: Int?
    
    var startable: TransactionStartable? = nil {
        didSet {
            if startable?.currency.code != oldValue?.currency.code {
                amount = nil
                amountConverted = nil
            }
        }
    }
    var completable: TransactionCompletable? = nil {
        didSet {
            if completable?.currency.code != oldValue?.currency.code {
                convertedAmount = nil
                convertedAmountConverted = nil
            }
        }
    }
    var amount: String? = nil {
        didSet {
            updateConvertedAmountConverted()
            
        }
    }
    var convertedAmount: String? = nil {
        didSet {
            updateAmountConverted()
        }
    }
    var comment: String? = nil
    var gotAt: Date? = nil
    var amountConverted: String? = nil
    var convertedAmountConverted: String? = nil
    
    var title: String { return "" }
    var removeTitle: String? { return nil }
    var removeQuestion: String? { return nil }
    var startableTitle: String? { return nil }
    var completableTitle: String? { return nil }
    var startableAmountTitle: String? { return "Сумма" }
    var completableAmountTitle: String? { return "Сумма" }
    var amountPlaceholder: String? {
        return amountConverted ?? startableAmountTitle
    }
    var convertedAmountPlaceholder: String? {
        return convertedAmountConverted ?? completableAmountTitle
    }
    
    var isNew: Bool { return transactionableId == nil }
    
    var hasComment: Bool {
        guard let comment = comment else { return false }
        return !comment.isEmpty && !comment.isWhitespace
    }
    
    var hasGotAtDate: Bool { return gotAt != nil }
    
    var calendarTitle: String {
        return hasGotAtDate ? gotAt!.dateTimeString(ofStyle: .short) : "Выбрать дату"
    }
    
    var startableIconURL: URL? { return startable?.iconURL }
    
    var startableIconDefaultImageName: String { return "" }
    
    var completableIconURL: URL? { return completable?.iconURL }
    
    var completableIconDefaultImageName: String { return "" }
    
    var startableName: String? { return startable?.name }
    
    var completableName: String? { return completable?.name }
    
    var startableAmount: String? { return startable?.amount }
    
    var completableAmount: String? { return completable?.amount }
    
    var startableCurrency: Currency? { return startable?.currency }
    
    var completableCurrency: Currency? { return completable?.currency }
    
    var startableCurrencyCode: String? { return startableCurrency?.code }
    
    var completableCurrencyCode: String? { return completableCurrency?.code }
    
    var needCurrencyExchange: Bool {
        return startableCurrency?.code != completableCurrency?.code
    }
    
    var exchangeRate: Float = 1.0 {
        didSet {
            updateAmountConverted()
            updateConvertedAmountConverted()
        }
    }
    
    var removeButtonHidden: Bool { return isNew }
    
    init(exchangeRatesCoordinator: ExchangeRatesCoordinatorProtocol,
         currencyConverter: CurrencyConverterProtocol) {
        self.exchangeRatesCoordinator = exchangeRatesCoordinator
        self.currencyConverter = currencyConverter
    }
    
    func updateAmountConverted() {
        amountConverted = convert(amount: convertedAmount, isForwardConversion: false)
    }
    
    func updateConvertedAmountConverted() {
        convertedAmountConverted = convert(amount: amount, isForwardConversion: true)
    }
    
    func loadData() -> Promise<Void> {
        if isNew {
            return loadExchangeRate()
        }
        return loadTransaction()
    }
    
    func loadTransactionPromise(transactionableId: Int) -> Promise<Void> {
        return Promise.value(())
    }
    
    func convert(amount: String?, isForwardConversion: Bool = true) -> String? {
        guard   let currency = startableCurrency,
                let convertedCurrency = completableCurrency,
            let amountCents = amount?.intMoney(with: isForwardConversion ? currency : convertedCurrency) else { return nil }
        
        let convertedAmountCents = currencyConverter.convert(cents: amountCents, fromCurrency: currency, toCurrency: convertedCurrency, exchangeRate: Double(exchangeRate), forward: isForwardConversion)
            
        return convertedAmountCents.moneyDecimalString(with: isForwardConversion ? convertedCurrency : currency)
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
    
    func loadTransaction() -> Promise<Void> {
        guard let transactionableId = transactionableId else {
            return Promise(error: TransactionError.transactionIsNotSpecified)
        }
        return  firstly {
                    loadTransactionPromise(transactionableId: transactionableId)
                }.then {
                    self.loadExchangeRate()
                }
    }
    
    func isFormValid() -> Bool {
        return isNew
            ? isCreationFormValid()
            : isUpdatingFormValid()
    }
    
    func save() -> Promise<Void> {
        return isNew
            ? create()
            : update()
    }
    
    func create() -> Promise<Void> {
        return Promise.value(())
    }
    
    func update() -> Promise<Void> {
        return Promise.value(())
    }
    
    func isCreationFormValid() -> Bool {
        return false
    }
    
    func isUpdatingFormValid() -> Bool {
        return false
    }
}
