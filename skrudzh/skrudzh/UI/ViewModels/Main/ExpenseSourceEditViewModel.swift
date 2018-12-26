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
        return expenseSource?.amount
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
    
    func isFormValid(with name: String?, amount: String?) -> Bool {
        return isNew ? isCreationFormValid(with: name) : isUpdatingFormValid(with: name)
    }
    
    func saveIncomeSource(with name: String?) -> Promise<Void> {
        return isNew ? createIncomeSource(with: name) : updateIncomeSource(with: name)
    }
    
    func removeIncomeSource() -> Promise<Void> {
        guard let incomeSourceId = incomeSource?.id else {
            return Promise(error: IncomeSourceUpdatingError.updatingIncomeSourceIsNotSpecified)
        }
        return incomeSourcesCoordinator.destroy(by: incomeSourceId)
    }
    
    private func isCreationFormValid(with name: String?, amount: String?) -> Bool {
        return validateCreation(with: name) == nil
    }
    
    private func isUpdatingFormValid(with name: String?, amount: String?) -> Bool {
        return validateUpdating(with: name) == nil
    }
    
    private func createIncomeSource(with name: String?) -> Promise<Void> {
        return  firstly {
            validateCreationForm(with: name)
            }.then { incomeSourceCreationForm -> Promise<IncomeSource> in
                self.incomeSourcesCoordinator.create(with: incomeSourceCreationForm)
            }.asVoid()
    }
    
    private func updateIncomeSource(with name: String?) -> Promise<Void> {
        return  firstly {
            validateUpdatingForm(with: name)
            }.then { incomeSourceUpdatingForm in
                self.incomeSourcesCoordinator.update(with: incomeSourceUpdatingForm)
        }
    }
    
    private func validateCreationForm(with name: String?, amount: String?) -> Promise<IncomeSourceCreationForm> {
        
        if let failureResultsHash = validateCreation(with: name) {
            return Promise(error: IncomeSourceCreationError.validation(validationResults: failureResultsHash))
        }
        
        guard let currentUserId = accountCoordinator.currentSession?.userId else {
            return Promise(error: IncomeSourceCreationError.currentSessionDoesNotExist)
        }
        
        return .value(IncomeSourceCreationForm(userId: currentUserId,
                                               name: name!))
    }
    
    private func validateUpdatingForm(with name: String?, amount: String?) -> Promise<IncomeSourceUpdatingForm> {
        
        if let failureResultsHash = validateUpdating(with: name) {
            return Promise(error: IncomeSourceUpdatingError.validation(validationResults: failureResultsHash))
        }
        
        guard let incomeSourceId = incomeSource?.id else {
            return Promise(error: IncomeSourceUpdatingError.updatingIncomeSourceIsNotSpecified)
        }
        
        return .value(IncomeSourceUpdatingForm(id: incomeSourceId,
                                               name: name!))
    }
    
    private func validateCreation(with name: String?, amount: String?) -> [IncomeSourceCreationForm.CodingKeys : [ValidationErrorReason]]? {
        let validationResults : [ValidationResultProtocol] =
            [Validator.validate(required: name, key: IncomeSourceCreationForm.CodingKeys.name)]
        
        let failureResultsHash : [IncomeSourceCreationForm.CodingKeys : [ValidationErrorReason]]? = Validator.failureResultsHash(from: validationResults)
        
        return failureResultsHash
    }
    
    private func validateUpdating(with name: String?, amount: String?) -> [IncomeSourceUpdatingForm.CodingKeys : [ValidationErrorReason]]? {
        
        let validationResults : [ValidationResultProtocol] =
            [Validator.validate(required: name, key: IncomeSourceUpdatingForm.CodingKeys.name)]
        
        let failureResultsHash : [IncomeSourceUpdatingForm.CodingKeys : [ValidationErrorReason]]? = Validator.failureResultsHash(from: validationResults)
        
        return failureResultsHash
    }
}
