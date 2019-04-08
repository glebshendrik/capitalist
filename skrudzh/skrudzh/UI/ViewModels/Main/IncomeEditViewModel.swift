//
//  IncomeEditViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 27/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

enum IncomeCreationError : Error {
    case validation(validationResults: [IncomeCreationForm.CodingKeys : [ValidationErrorReason]])
    case currentSessionDoesNotExist
    case currencyIsNotSpecified
    case incomeSourceIsNotSpecified
    case expenseSourceIsNotSpecified
}

enum IncomeUpdatingError : Error {
    case validation(validationResults: [IncomeUpdatingForm.CodingKeys : [ValidationErrorReason]])
    case updatingIncomeIsNotSpecified
    case currencyIsNotSpecified
    case incomeSourceIsNotSpecified
    case expenseSourceIsNotSpecified
}


class IncomeEditViewModel : TransactionEditViewModel {
    private let incomesCoordinator: IncomesCoordinatorProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    
    private var income: Income? = nil    
    
    var incomeSourceStartable: IncomeSourceViewModel? {
        return startable as? IncomeSourceViewModel
    }
    
    var expenseSourceCompletable: ExpenseSourceViewModel? {
        return completable as? ExpenseSourceViewModel
    }
    
    override var title: String? {
        return isNew ? "Новый доход" : "Изменить доход"
    }
    
    override var removeTitle: String? {
        return isNew ? nil : "Удалить доход"
    }
    
    override var startableTitle: String? {
        return "Источник доходов"
    }
    
    override var completableTitle: String? {
        return "Кошелек для пополнения"
    }
    
    override var startableAmountTitle: String? {
        return "Сумма дохода"
    }
    
    override var completableAmountTitle: String? {
        return "Сумма пополнения"
    }
    
    override var amount: String? {
        guard let currency = startableCurrency else { return nil }
        return income?.amountCents.moneyDecimalString(with: currency)
    }
    
    override var convertedAmount: String? {
        guard let convertedCurrency = completableCurrency else { return nil }
        return income?.convertedAmountCents.moneyDecimalString(with: convertedCurrency)
    }
    
    override var startableIconDefaultImageName: String {
        return "lamp-icon"
    }
    
    override var completableIconDefaultImageName: String {
        return "expense-source-icon"
    }
    
    init(incomesCoordinator: IncomesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         exchangeRatesCoordinator: ExchangeRatesCoordinatorProtocol,
         currencyConverter: CurrencyConverterProtocol) {
        self.incomesCoordinator = incomesCoordinator
        self.accountCoordinator = accountCoordinator
        super.init(exchangeRatesCoordinator: exchangeRatesCoordinator, currencyConverter: currencyConverter)
    }
    
    func set(incomeId: Int) {
        transactionableId = incomeId
    }
    
    func set(income: Income) {
        self.income = income
        self.comment = income.comment
        self.gotAt = income.gotAt
        self.startable = IncomeSourceViewModel(incomeSource: income.incomeSource)
        self.completable = ExpenseSourceViewModel(expenseSource: income.expenseSource)
    }
    
    func set(startable: IncomeSourceViewModel, completable: ExpenseSourceViewModel) {
        self.startable = startable
        self.completable = completable
    }
    
    override func loadTransactionPromise(transactionableId: Int) -> Promise<Void> {
        return  firstly {
                    incomesCoordinator.show(by: transactionableId)
                }.get { income in
                    self.set(income: income)
                }.asVoid()
    }
    
    func isFormValid(amount: String?,
                     convertedAmount: String?,
                     comment: String?,
                     gotAt: Date?) -> Bool {
        
        guard let currency = startableCurrency,
              let convertedCurrency = completableCurrency else { return false }
        
        let amountCents = amount?.intMoney(with: currency)
        let convertedAmountCents = convertedAmount?.intMoney(with: convertedCurrency)
        
        return isNew
            ? isCreationFormValid(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt)
            : isUpdatingFormValid(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt)
    }
    
    func saveIncome(amount: String?,
                    convertedAmount: String?,
                    comment: String?,
                    gotAt: Date?) -> Promise<Void> {
        
        guard   let currency = startableCurrency,
                let convertedCurrency = completableCurrency else {
            
                return Promise(error: IncomeCreationError.currencyIsNotSpecified)
        }
        
        let amountCents = amount?.intMoney(with: currency)
        let convertedAmountCents = convertedAmount?.intMoney(with: convertedCurrency)
        
        return isNew
            ? createIncome(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt)
            : updateIncome(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt)
    }
    
    func removeIncome() -> Promise<Void> {
        guard let incomeId = income?.id else {
            return Promise(error: IncomeUpdatingError.updatingIncomeIsNotSpecified)
        }
        return incomesCoordinator.destroy(by: incomeId)
    }
}

// Creation
extension IncomeEditViewModel {
    private func isCreationFormValid(amountCents: Int?,
                                     convertedAmountCents: Int?,
                                     comment: String?,
                                     gotAt: Date?) -> Bool {
        return validateCreation(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt) == nil
    }
    
    private func createIncome(amountCents: Int?,
                              convertedAmountCents: Int?,
                              comment: String?,
                              gotAt: Date?) -> Promise<Void> {
        return  firstly {
                    validateCreationForm(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt)
                }.then { incomeCreationForm -> Promise<Income> in
                    self.incomesCoordinator.create(with: incomeCreationForm)
                }.asVoid()
    }
    
    private func validateCreationForm(amountCents: Int?,
                                      convertedAmountCents: Int?,
                                      comment: String?,
                                      gotAt: Date?) -> Promise<IncomeCreationForm> {
        
        if let failureResultsHash = validateCreation(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt) {
            return Promise(error: IncomeCreationError.validation(validationResults: failureResultsHash))
        }
        
        guard let currentUserId = accountCoordinator.currentSession?.userId else {
            return Promise(error: IncomeCreationError.currentSessionDoesNotExist)
        }
        
        guard   let currencyCode = startableCurrency?.code,
                let convertedCurrencyCode = completableCurrency?.code else {
            return Promise(error: IncomeCreationError.currencyIsNotSpecified)
        }
        
        guard let incomeSourceId = incomeSourceStartable?.id else {
            return Promise(error: IncomeCreationError.incomeSourceIsNotSpecified)
        }
        
        guard let expenseSourceId = expenseSourceCompletable?.id else {
            return Promise(error: IncomeCreationError.expenseSourceIsNotSpecified)
        }
        
        return .value(IncomeCreationForm(userId: currentUserId,
                                         incomeSourceId: incomeSourceId,
                                         expenseSourceId: expenseSourceId,
                                         amountCents: amountCents!,
                                         amountCurrency: currencyCode,
                                         convertedAmountCents: convertedAmountCents!,
                                         convertedAmountCurrency: convertedCurrencyCode,
                                         gotAt: gotAt!,
                                         comment: comment))
    }
    
    private func validateCreation(amountCents: Int?,
                                  convertedAmountCents: Int?,
                                  comment: String?,
                                  gotAt: Date?) -> [IncomeCreationForm.CodingKeys : [ValidationErrorReason]]? {
        
        let validationResults : [ValidationResultProtocol] =
            [Validator.validate(pastDate: gotAt, key: IncomeCreationForm.CodingKeys.gotAt),
             Validator.validate(positiveMoney: amountCents, key: IncomeCreationForm.CodingKeys.amountCents),
             Validator.validate(positiveMoney: convertedAmountCents, key: IncomeCreationForm.CodingKeys.convertedAmountCents)]
        
        let failureResultsHash : [IncomeCreationForm.CodingKeys : [ValidationErrorReason]]? = Validator.failureResultsHash(from: validationResults)
        
        return failureResultsHash
    }
}

// Updating
extension IncomeEditViewModel {
    private func isUpdatingFormValid(amountCents: Int?,
                                     convertedAmountCents: Int?,
                                     comment: String?,
                                     gotAt: Date?) -> Bool {
        return validateUpdating(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt) == nil
    }
    
    private func updateIncome(amountCents: Int?,
                              convertedAmountCents: Int?,
                              comment: String?,
                              gotAt: Date?) -> Promise<Void> {
        return  firstly {
                    validateUpdatingForm(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt)
                }.then { incomeUpdatingForm -> Promise<Void> in
                    self.incomesCoordinator.update(with: incomeUpdatingForm)
                }
    }
    
    private func validateUpdatingForm(amountCents: Int?,
                                      convertedAmountCents: Int?,
                                      comment: String?,
                                      gotAt: Date?) -> Promise<IncomeUpdatingForm> {
        
        if let failureResultsHash = validateUpdating(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt) {
            return Promise(error: IncomeUpdatingError.validation(validationResults: failureResultsHash))
        }
        
        guard let incomeId = income?.id else {
            return Promise(error: IncomeUpdatingError.updatingIncomeIsNotSpecified)
        }
        
        guard   let currencyCode = startableCurrency?.code,
                let convertedCurrencyCode = completableCurrency?.code else {
                return Promise(error: IncomeUpdatingError.currencyIsNotSpecified)
        }
        
        guard let incomeSourceId = incomeSourceStartable?.id else {
            return Promise(error: IncomeUpdatingError.incomeSourceIsNotSpecified)
        }
        
        guard let expenseSourceId = expenseSourceCompletable?.id else {
            return Promise(error: IncomeUpdatingError.expenseSourceIsNotSpecified)
        }
        
        return .value(IncomeUpdatingForm(id: incomeId,
                                         incomeSourceId: incomeSourceId,
                                         expenseSourceId: expenseSourceId,
                                         amountCents: amountCents!,
                                         amountCurrency: currencyCode,
                                         convertedAmountCents: convertedAmountCents!,
                                         convertedAmountCurrency: convertedCurrencyCode,
                                         gotAt: gotAt!,
                                         comment: comment))
    }
    
    private func validateUpdating(amountCents: Int?,
                                  convertedAmountCents: Int?,
                                  comment: String?,
                                  gotAt: Date?) -> [IncomeUpdatingForm.CodingKeys : [ValidationErrorReason]]? {
        
        let validationResults : [ValidationResultProtocol] =
            [Validator.validate(pastDate: gotAt, key: IncomeUpdatingForm.CodingKeys.gotAt),
             Validator.validate(positiveMoney: amountCents, key: IncomeUpdatingForm.CodingKeys.amountCents),
             Validator.validate(positiveMoney: convertedAmountCents, key: IncomeUpdatingForm.CodingKeys.convertedAmountCents)]
        
        let failureResultsHash : [IncomeUpdatingForm.CodingKeys : [ValidationErrorReason]]? = Validator.failureResultsHash(from: validationResults)
        
        return failureResultsHash
    }
}
