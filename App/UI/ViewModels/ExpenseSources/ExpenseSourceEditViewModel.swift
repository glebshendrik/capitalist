//
//  ExpenseSourceEditViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum ExpenseSourceCreationError : Error {
    case validation(validationResults: [ExpenseSourceCreationForm.CodingKeys : [ValidationErrorReason]])
    case currentSessionDoesNotExist
    case currencyIsNotSpecified
}

enum ExpenseSourceUpdatingError : Error {
    case validation(validationResults: [ExpenseSourceUpdatingForm.CodingKeys : [ValidationErrorReason]])
    case updatingExpenseSourceIsNotSpecified
}


class ExpenseSourceEditViewModel {
    private let expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    
    private var expenseSource: ExpenseSource? = nil
    
    var name: String? {
        return expenseSource?.name
    }
            
    var amount: String? {
        guard let currency = selectedCurrency else { return nil }
        return (expenseSource?.amountCents ?? 0).moneyDecimalString(with: currency)
    }
    
    var creditLimit: String? {
        guard let currency = selectedCurrency else { return nil }
        return (expenseSource?.creditLimitCents ?? 0).moneyDecimalString(with: currency)
    }
        
    var goalAmount: String? {
        guard let currency = selectedCurrency else { return nil }
        return expenseSource?.goalAmountCents?.moneyDecimalString(with: currency)
    }
    
    var iconURL: URL? {
        return expenseSource?.iconURL
    }
    
    var selectedIconURL: URL?
    
    var selectedCurrency: Currency? = nil
    
    var selectedCurrencyName: String? {
        return selectedCurrency?.translatedName
    }
    
    var selectedCurrencyCode: String? {
        return selectedCurrency?.code
    }
    
    var isNew: Bool {
        return expenseSource == nil
    }
    
    var canChangeCurrency: Bool {
        return isNew
    }
    
    var canChangeAmount: Bool {
        return isNew || accountType != .debt
    }
    
    var amountHidden: Bool {
        return isNew && accountType == .debt
    }
    
    var creditLimitHidden: Bool {
        return accountType != .usual
    }
        
    var accountType: AccountType = .usual
    
    var isGoal: Bool {
        return accountType == .goal
    }
    
    var bankButtonHidden: Bool {
        return accountType != .usual
    }
    
    init(expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol) {
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
        self.accountCoordinator = accountCoordinator
    }
    
    func set(expenseSource: ExpenseSource) {
        self.expenseSource = expenseSource
        selectedIconURL = iconURL
        accountType = expenseSource.accountType
        selectedCurrency = expenseSource.currency
    }
    
    func loadDefaultCurrency() -> Promise<Void> {
        return  firstly {
                    accountCoordinator.loadCurrentUser()
                }.done { user in
                    self.selectedCurrency = user.currency
                }
    }
    
    func isFormValid(with name: String?,
                     amount: String?,
                     iconURL: URL?,
                     goalAmount: String?,
                     creditLimit: String?) -> Bool {
        guard let currency = selectedCurrency else { return false }
        
        let amountCents = amount?.intMoney(with: currency)
        let creditLimitCents = creditLimit?.intMoney(with: currency)
        let goalAmountCents = goalAmount?.intMoney(with: currency)
        
        return isNew
            ? isCreationFormValid(with: name, amountCents: amountCents, iconURL: iconURL, goalAmountCents: goalAmountCents, creditLimitCents: creditLimitCents)
            : isUpdatingFormValid(with: name, amountCents: amountCents, iconURL: iconURL, goalAmountCents: goalAmountCents, creditLimitCents: creditLimitCents)
    }
    
    func saveExpenseSource(with name: String?,
                           amount: String?,
                           iconURL: URL?,
                           goalAmount: String?,
                           creditLimit: String?) -> Promise<Void> {
        guard let currency = selectedCurrency else {
            return Promise(error: ExpenseSourceCreationError.currencyIsNotSpecified)
        }
        
        let amountCents = amount?.intMoney(with: currency)
        let creditLimitCents = creditLimit?.intMoney(with: currency)
        let goalAmountCents = goalAmount?.intMoney(with: currency)
        
        return isNew
            ? createExpenseSource(with: name, amountCents: amountCents, iconURL: iconURL, goalAmountCents: goalAmountCents, creditLimitCents: creditLimitCents)
            : updateExpenseSource(with: name, amountCents: amountCents, iconURL: iconURL, goalAmountCents: goalAmountCents, creditLimitCents: creditLimitCents)
    }
    
    func removeExpenseSource(deleteTransactions: Bool) -> Promise<Void> {
        guard let expenseSourceId = expenseSource?.id else {
            return Promise(error: ExpenseSourceUpdatingError.updatingExpenseSourceIsNotSpecified)
        }
        return expenseSourcesCoordinator.destroy(by: expenseSourceId, deleteTransactions: deleteTransactions)
    }
    
    
}

// Creation
extension ExpenseSourceEditViewModel {
    private func createExpenseSource(with name: String?,
                                     amountCents: Int?,
                                     iconURL: URL?,
                                     goalAmountCents: Int?,
                                     creditLimitCents: Int?) -> Promise<Void> {
        return  firstly {
            validateCreationForm(with: name, amountCents: amountCents, iconURL: iconURL, goalAmountCents: goalAmountCents, creditLimitCents: creditLimitCents)
            }.then { expenseSourceCreationForm -> Promise<ExpenseSource> in
                self.expenseSourcesCoordinator.create(with: expenseSourceCreationForm)
            }.asVoid()
    }
    
    
    
    
    
    private func validateCreationForm(with name: String?,
                                      amountCents: Int?,
                                      iconURL: URL?,
                                      goalAmountCents: Int?,
                                      creditLimitCents: Int?) -> Promise<ExpenseSourceCreationForm> {
        
        if let failureResultsHash = validateCreation(with: name, amountCents: amountCents, iconURL: iconURL, goalAmountCents: goalAmountCents, creditLimitCents: creditLimitCents) {
            return Promise(error: ExpenseSourceCreationError.validation(validationResults: failureResultsHash))
        }
        
        guard let currentUserId = accountCoordinator.currentSession?.userId else {
            return Promise(error: ExpenseSourceCreationError.currentSessionDoesNotExist)
        }
        
        guard let currencyCode = selectedCurrencyCode else {
            return Promise(error: ExpenseSourceCreationError.currencyIsNotSpecified)
        }
        
        return .value(ExpenseSourceCreationForm(userId: currentUserId,
                                                name: name!,
                                                iconURL: iconURL,
                                                amountCurrency: currencyCode,
                                                amountCents: amountCents!,
                                                accountType: accountType,
                                                goalAmountCents: goalAmountCents,
                                                goalAmountCurrency: currencyCode,
                                                creditLimitCents: creditLimitCents,
                                                creditLimitCurrency: currencyCode))
    }
    
    private func validateCreation(with name: String?,
                                  amountCents: Int?,
                                  iconURL: URL?,
                                  goalAmountCents: Int?,
                                  creditLimitCents: Int?) -> [ExpenseSourceCreationForm.CodingKeys : [ValidationErrorReason]]? {
        var validationResults : [ValidationResultProtocol] =
            [Validator.validate(required: name, key: ExpenseSourceCreationForm.CodingKeys.name),
             Validator.validate(money: amountCents, key: ExpenseSourceCreationForm.CodingKeys.amountCents)]
        
        if accountType == .goal {
            validationResults.append(Validator.validate(money: goalAmountCents, key: ExpenseSourceCreationForm.CodingKeys.goalAmountCents))
        }
        
        if accountType == .usual {
            validationResults.append(Validator.validate(money: creditLimitCents, key: ExpenseSourceCreationForm.CodingKeys.creditLimitCents))
        }
        
        let failureResultsHash : [ExpenseSourceCreationForm.CodingKeys : [ValidationErrorReason]]? = Validator.failureResultsHash(from: validationResults)
        
        return failureResultsHash
    }
    
    private func isCreationFormValid(with name: String?,
                                     amountCents: Int?,
                                     iconURL: URL?,
                                     goalAmountCents: Int?,
                                     creditLimitCents: Int?) -> Bool {
        return validateCreation(with: name, amountCents: amountCents, iconURL: iconURL, goalAmountCents: goalAmountCents, creditLimitCents: creditLimitCents) == nil
    }
}

// Updating
extension ExpenseSourceEditViewModel {
    private func updateExpenseSource(with name: String?,
                                     amountCents: Int?,
                                     iconURL: URL?,
                                     goalAmountCents: Int?,
                                     creditLimitCents: Int?) -> Promise<Void> {
        return  firstly {
            validateUpdatingForm(with: name, amountCents: amountCents, iconURL: iconURL, goalAmountCents: goalAmountCents, creditLimitCents: creditLimitCents)
                }.then { expenseSourceUpdatingForm in
                    self.expenseSourcesCoordinator.update(with: expenseSourceUpdatingForm)
                }
    }
    
    private func validateUpdatingForm(with name: String?,
                                      amountCents: Int?,
                                      iconURL: URL?,
                                      goalAmountCents: Int?,
                                      creditLimitCents: Int?) -> Promise<ExpenseSourceUpdatingForm> {
        
        if let failureResultsHash = validateUpdating(with: name, amountCents: amountCents, iconURL: iconURL, goalAmountCents: goalAmountCents, creditLimitCents: creditLimitCents) {
            return Promise(error: ExpenseSourceUpdatingError.validation(validationResults: failureResultsHash))
        }
        
        guard let expenseSourceId = expenseSource?.id else {
            return Promise(error: ExpenseSourceUpdatingError.updatingExpenseSourceIsNotSpecified)
        }
        
        return .value(ExpenseSourceUpdatingForm(id: expenseSourceId,
                                                name: name!,
                                                amountCents: amountCents!,
                                                iconURL: iconURL,
                                                goalAmountCents: goalAmountCents,
                                                creditLimitCents: creditLimitCents))
    }
    
    private func validateUpdating(with name: String?,
                                  amountCents: Int?,
                                  iconURL: URL?,
                                  goalAmountCents: Int?,
                                  creditLimitCents: Int?) -> [ExpenseSourceUpdatingForm.CodingKeys : [ValidationErrorReason]]? {
        
        var validationResults : [ValidationResultProtocol] =
            [Validator.validate(required: name, key: ExpenseSourceUpdatingForm.CodingKeys.name),
             Validator.validate(balance: amountCents, key: ExpenseSourceUpdatingForm.CodingKeys.amountCents)]
        
        if accountType == .goal {
            validationResults.append(Validator.validate(money: goalAmountCents, key: ExpenseSourceUpdatingForm.CodingKeys.goalAmountCents))
        }
        
        if accountType == .usual {
            validationResults.append(Validator.validate(money: creditLimitCents, key: ExpenseSourceUpdatingForm.CodingKeys.creditLimitCents))
        }
        
        let failureResultsHash : [ExpenseSourceUpdatingForm.CodingKeys : [ValidationErrorReason]]? = Validator.failureResultsHash(from: validationResults)
        
        return failureResultsHash
    }
    
    private func isUpdatingFormValid(with name: String?,
                                     amountCents: Int?,
                                     iconURL: URL?,
                                     goalAmountCents: Int?,
                                     creditLimitCents: Int?) -> Bool {
        return validateUpdating(with: name, amountCents: amountCents, iconURL: iconURL, goalAmountCents: goalAmountCents, creditLimitCents: creditLimitCents) == nil
    }
}
