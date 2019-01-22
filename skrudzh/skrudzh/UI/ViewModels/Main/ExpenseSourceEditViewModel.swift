//
//  ExpenseSourceEditViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 26/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

enum ExpenseSourceCreationError : Error {
    case validation(validationResults: [ExpenseSourceCreationForm.CodingKeys : [ValidationErrorReason]])
    case currentSessionDoesNotExist
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
        return (expenseSource?.amountCents ?? 0).moneyDecimalString
    }
    
    var iconURL: URL? {
        return expenseSource?.iconURL
    }
    
    var selectedIconURL: URL?
    
    var isNew: Bool {
        return expenseSource == nil
    }
    
    init(expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol) {
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
        self.accountCoordinator = accountCoordinator
    }
    
    func set(expenseSource: ExpenseSource) {
        self.expenseSource = expenseSource
        selectedIconURL = iconURL
    }
    
    func isFormValid(with name: String?,
                     amount: String?,
                     iconURL: URL?) -> Bool {
        let amountCents = amount?.intMoney
        return isNew
            ? isCreationFormValid(with: name, amountCents: amountCents, iconURL: iconURL)
            : isUpdatingFormValid(with: name, amountCents: amountCents, iconURL: iconURL)
    }
    
    func saveExpenseSource(with name: String?,
                           amount: String?,
                           iconURL: URL?) -> Promise<Void> {
        let amountCents = amount?.intMoney
        return isNew
            ? createExpenseSource(with: name, amountCents: amountCents, iconURL: iconURL)
            : updateExpenseSource(with: name, amountCents: amountCents, iconURL: iconURL)
    }
    
    func removeExpenseSource() -> Promise<Void> {
        guard let expenseSourceId = expenseSource?.id else {
            return Promise(error: ExpenseSourceUpdatingError.updatingExpenseSourceIsNotSpecified)
        }
        return expenseSourcesCoordinator.destroy(by: expenseSourceId)
    }
    
    
}

// Creation
extension ExpenseSourceEditViewModel {
    private func isCreationFormValid(with name: String?,
                                     amountCents: Int?,
                                     iconURL: URL?) -> Bool {
        return validateCreation(with: name, amountCents: amountCents, iconURL: iconURL) == nil
    }
    
    private func createExpenseSource(with name: String?,
                                     amountCents: Int?,
                                     iconURL: URL?) -> Promise<Void> {
        return  firstly {
                    validateCreationForm(with: name, amountCents: amountCents, iconURL: iconURL)
                }.then { expenseSourceCreationForm -> Promise<ExpenseSource> in
                    self.expenseSourcesCoordinator.create(with: expenseSourceCreationForm)
                }.asVoid()
    }
    
    private func validateCreationForm(with name: String?,
                                      amountCents: Int?,
                                      iconURL: URL?) -> Promise<ExpenseSourceCreationForm> {
        
        if let failureResultsHash = validateCreation(with: name, amountCents: amountCents, iconURL: iconURL) {
            return Promise(error: ExpenseSourceCreationError.validation(validationResults: failureResultsHash))
        }
        
        guard let currentUserId = accountCoordinator.currentSession?.userId else {
            return Promise(error: ExpenseSourceCreationError.currentSessionDoesNotExist)
        }
        
        return .value(ExpenseSourceCreationForm(userId: currentUserId,
                                                name: name!,
                                                amountCents: amountCents!,
                                                iconURL: iconURL))
    }
    
    private func validateCreation(with name: String?,
                                  amountCents: Int?,
                                  iconURL: URL?) -> [ExpenseSourceCreationForm.CodingKeys : [ValidationErrorReason]]? {
        let validationResults : [ValidationResultProtocol] =
            [Validator.validate(required: name, key: ExpenseSourceCreationForm.CodingKeys.name),
             Validator.validate(money: amountCents, key: ExpenseSourceCreationForm.CodingKeys.amountCents)]
        
        let failureResultsHash : [ExpenseSourceCreationForm.CodingKeys : [ValidationErrorReason]]? = Validator.failureResultsHash(from: validationResults)
        
        return failureResultsHash
    }
}

// Updating
extension ExpenseSourceEditViewModel {
    private func isUpdatingFormValid(with name: String?,
                                     amountCents: Int?,
                                     iconURL: URL?) -> Bool {
        return validateUpdating(with: name, amountCents: amountCents, iconURL: iconURL) == nil
    }
    
    private func updateExpenseSource(with name: String?,
                                     amountCents: Int?,
                                     iconURL: URL?) -> Promise<Void> {
        return  firstly {
                    validateUpdatingForm(with: name, amountCents: amountCents, iconURL: iconURL)
                }.then { expenseSourceUpdatingForm in
                    self.expenseSourcesCoordinator.update(with: expenseSourceUpdatingForm)
                }
    }
    
    private func validateUpdatingForm(with name: String?,
                                      amountCents: Int?,
                                      iconURL: URL?) -> Promise<ExpenseSourceUpdatingForm> {
        
        if let failureResultsHash = validateUpdating(with: name, amountCents: amountCents, iconURL: iconURL) {
            return Promise(error: ExpenseSourceUpdatingError.validation(validationResults: failureResultsHash))
        }
        
        guard let expenseSourceId = expenseSource?.id else {
            return Promise(error: ExpenseSourceUpdatingError.updatingExpenseSourceIsNotSpecified)
        }
        
        return .value(ExpenseSourceUpdatingForm(id: expenseSourceId,
                                                name: name!,
                                                amountCents: amountCents!,
                                                iconURL: iconURL))
    }
    
    private func validateUpdating(with name: String?,
                                  amountCents: Int?,
                                  iconURL: URL?) -> [ExpenseSourceUpdatingForm.CodingKeys : [ValidationErrorReason]]? {
        
        let validationResults : [ValidationResultProtocol] =
            [Validator.validate(required: name, key: ExpenseSourceUpdatingForm.CodingKeys.name),
             Validator.validate(money: amountCents, key: ExpenseSourceUpdatingForm.CodingKeys.amountCents)]
        
        let failureResultsHash : [ExpenseSourceUpdatingForm.CodingKeys : [ValidationErrorReason]]? = Validator.failureResultsHash(from: validationResults)
        
        return failureResultsHash
    }
}
