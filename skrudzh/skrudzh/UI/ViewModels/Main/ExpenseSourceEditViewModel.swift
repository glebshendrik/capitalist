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
        
    var amountCents: Int? {
        return expenseSource?.amountCents
    }
    
    var amountNumber: NSDecimalNumber? {
        guard let cents = amountCents else { return nil }
        return NSDecimalNumber(value: cents).dividing(by: 100)
    }
    
    var iconURL: URL? {
        return expenseSource?.iconURL
    }
    
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
    }
    
    func isFormValid(with name: String?,
                     amount: String?,
                     iconURL: URL?) -> Bool {
        let amountCents = formatToCents(amount)
        return isNew
            ? isCreationFormValid(with: name, amountCents: amountCents, iconURL: iconURL)
            : isUpdatingFormValid(with: name, amountCents: amountCents, iconURL: iconURL)
    }
    
    func saveExpenseSource(with name: String?,
                           amount: String?,
                           iconURL: URL?) -> Promise<Void> {
        let amountCents = formatToCents(amount)
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
    
    private func formatToCents(_ amount: String?) -> Int? {
        guard let stringAmount = amount else {
            return nil
            
        }
        
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.numberStyle = NumberFormatter.Style.decimal
        
        guard let decimal = formatter.number(from: stringAmount) as? NSDecimalNumber else {
            return nil
        }
        return decimal.multiplying(by: 100).intValue
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
