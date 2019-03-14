//
//  ExpenseCategoryEditViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 17/01/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

enum ExpenseCategoryCreationError : Error {
    case validation(validationResults: [ExpenseCategoryCreationForm.CodingKeys : [ValidationErrorReason]])
    case basketIsNotSpecified
    case currencyIsNotSpecified
}

enum ExpenseCategoryUpdatingError : Error {
    case validation(validationResults: [ExpenseCategoryUpdatingForm.CodingKeys : [ValidationErrorReason]])
    case updatingExpenseCategoryIsNotSpecified
}


class ExpenseCategoryEditViewModel {
    private let expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    
    public private(set) var expenseCategory: ExpenseCategory? = nil
    public private(set) var basketType: BasketType? = nil
    
    var name: String? {
        return expenseCategory?.name
    }
    
    var monthlyPlanned: String? {
        guard let currency = selectedCurrency else { return nil }        
        return expenseCategory?.monthlyPlannedCents?.moneyDecimalString(with: currency)
    }
    
    var iconURL: URL? {
        return expenseCategory?.iconURL
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
        return expenseCategory == nil
    }
    
    init(expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol) {
        self.expenseCategoriesCoordinator = expenseCategoriesCoordinator
        self.accountCoordinator = accountCoordinator
    }
    
    func set(expenseCategory: ExpenseCategory) {
        self.expenseCategory = expenseCategory
        selectedIconURL = iconURL
        selectedCurrency = expenseCategory.currency
    }
    
    func loadDefaultCurrency() -> Promise<Void> {
        return  firstly {
                    accountCoordinator.loadCurrentUser()
                }.done { user in
                    self.selectedCurrency = user.currency
                }
    }
    
    func set(basketType: BasketType) {
        self.basketType = basketType
    }
    
    func isFormValid(with name: String?,
                     iconURL: URL?,
                     monthlyPlanned: String?) -> Bool {
        guard let currency = selectedCurrency else { return false }
        
        let monthlyPlannedCents = monthlyPlanned?.intMoney(with: currency)
        
        return isNew
            ? isCreationFormValid(with: name, iconURL: iconURL, monthlyPlannedCents: monthlyPlannedCents)
            : isUpdatingFormValid(with: name, iconURL: iconURL, monthlyPlannedCents: monthlyPlannedCents)
    }
    
    func saveExpenseCategory(with name: String?,
                             iconURL: URL?,
                             monthlyPlanned: String?) -> Promise<Void> {
        guard let currency = selectedCurrency else {
            return Promise(error: ExpenseCategoryCreationError.currencyIsNotSpecified)
        }        
        
        let monthlyPlannedCents = monthlyPlanned?.intMoney(with: currency)
        
        return isNew
            ? createExpenseCategory(with: name, iconURL: iconURL, monthlyPlannedCents: monthlyPlannedCents)
            : updateExpenseCategory(with: name, iconURL: iconURL, monthlyPlannedCents: monthlyPlannedCents)
    }
    
    func removeExpenseCategory(deleteTransactions: Bool) -> Promise<Void> {
        guard let expenseCategoryId = expenseCategory?.id else {
            return Promise(error: ExpenseCategoryUpdatingError.updatingExpenseCategoryIsNotSpecified)
        }
        return expenseCategoriesCoordinator.destroy(by: expenseCategoryId, deleteTransactions: deleteTransactions)
    }
    
    func basketId(by basketType: BasketType) -> Int? {
        guard let session = accountCoordinator.currentSession else { return nil }
        
        switch basketType {
        case .joy:
            return session.joyBasketId
        case .risk:
            return session.riskBasketId
        case .safe:
            return session.safeBasketId
        }
    }
}

// Creation
extension ExpenseCategoryEditViewModel {
    private func isCreationFormValid(with name: String?,
                                     iconURL: URL?,
                                     monthlyPlannedCents: Int?) -> Bool {
        return validateCreation(with: name, iconURL: iconURL, monthlyPlannedCents: monthlyPlannedCents) == nil
    }
    
    private func createExpenseCategory(with name: String?,
                                       iconURL: URL?,
                                       monthlyPlannedCents: Int?) -> Promise<Void> {
        return  firstly {
                    validateCreationForm(with: name, iconURL: iconURL, monthlyPlannedCents: monthlyPlannedCents)
                }.then { expenseCategoryCreationForm -> Promise<ExpenseCategory> in
                    self.expenseCategoriesCoordinator.create(with: expenseCategoryCreationForm)
                }.asVoid()
    }
    
    private func validateCreationForm(with name: String?,
                                      iconURL: URL?,
                                      monthlyPlannedCents: Int?) -> Promise<ExpenseCategoryCreationForm> {
        
        if let failureResultsHash = validateCreation(with: name, iconURL: iconURL, monthlyPlannedCents: monthlyPlannedCents) {
            return Promise(error: ExpenseCategoryCreationError.validation(validationResults: failureResultsHash))
        }
        
        guard   let basketType = basketType,
                let basketId = basketId(by: basketType) else {
            return Promise(error: ExpenseCategoryCreationError.basketIsNotSpecified)
        }
        
        guard let currencyCode = selectedCurrencyCode else {
            return Promise(error: ExpenseCategoryCreationError.currencyIsNotSpecified)
        }
        
        return .value(ExpenseCategoryCreationForm(name: name!,
                                                  iconURL: iconURL,
                                                  basketId: basketId,
                                                  monthlyPlannedCents: monthlyPlannedCents,
                                                  currency: currencyCode))
    }
    
    private func validateCreation(with name: String?,
                                  iconURL: URL?,
                                  monthlyPlannedCents: Int?) -> [ExpenseCategoryCreationForm.CodingKeys : [ValidationErrorReason]]? {
        let validationResults : [ValidationResultProtocol] =
            [Validator.validate(required: name, key: ExpenseCategoryCreationForm.CodingKeys.name)]
        
        let failureResultsHash : [ExpenseCategoryCreationForm.CodingKeys : [ValidationErrorReason]]? = Validator.failureResultsHash(from: validationResults)
        
        return failureResultsHash
    }
}

// Updating
extension ExpenseCategoryEditViewModel {
    private func isUpdatingFormValid(with name: String?,
                                     iconURL: URL?,
                                     monthlyPlannedCents: Int?) -> Bool {
        return validateUpdating(with: name, iconURL: iconURL, monthlyPlannedCents: monthlyPlannedCents) == nil
    }
    
    private func updateExpenseCategory(with name: String?,
                                       iconURL: URL?,
                                       monthlyPlannedCents: Int?) -> Promise<Void> {
        return  firstly {
                    validateUpdatingForm(with: name, iconURL: iconURL, monthlyPlannedCents: monthlyPlannedCents)
                }.then { expenseCategoryUpdatingForm in
                    self.expenseCategoriesCoordinator.update(with: expenseCategoryUpdatingForm)
                }
    }
    
    private func validateUpdatingForm(with name: String?,
                                      iconURL: URL?,
                                      monthlyPlannedCents: Int?) -> Promise<ExpenseCategoryUpdatingForm> {
        
        if let failureResultsHash = validateUpdating(with: name, iconURL: iconURL, monthlyPlannedCents: monthlyPlannedCents) {
            return Promise(error: ExpenseCategoryUpdatingError.validation(validationResults: failureResultsHash))
        }
        
        guard let expenseCategoryId = expenseCategory?.id else {
            return Promise(error: ExpenseCategoryUpdatingError.updatingExpenseCategoryIsNotSpecified)
        }
        
        return .value(ExpenseCategoryUpdatingForm(id: expenseCategoryId,
                                                  name: name!,
                                                  iconURL: iconURL,
                                                  monthlyPlannedCents: monthlyPlannedCents))
    }
    
    private func validateUpdating(with name: String?,
                                  iconURL: URL?,
                                  monthlyPlannedCents: Int?) -> [ExpenseCategoryUpdatingForm.CodingKeys : [ValidationErrorReason]]? {
        
        let validationResults : [ValidationResultProtocol] =
            [Validator.validate(required: name, key: ExpenseCategoryUpdatingForm.CodingKeys.name)]
        
        let failureResultsHash : [ExpenseCategoryUpdatingForm.CodingKeys : [ValidationErrorReason]]? = Validator.failureResultsHash(from: validationResults)
        
        return failureResultsHash
    }
}
