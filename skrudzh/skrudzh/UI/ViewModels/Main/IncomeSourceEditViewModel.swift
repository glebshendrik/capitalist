//
//  IncomeSourceEditViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 13/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

enum IncomeSourceCreationError : Error {
    case validation(validationResults: [IncomeSourceCreationForm.CodingKeys : [ValidationErrorReason]])
    case currentSessionDoesNotExist
    case currencyIsNotSpecified
}

enum IncomeSourceUpdatingError : Error {
    case validation(validationResults: [IncomeSourceUpdatingForm.CodingKeys : [ValidationErrorReason]])
    case updatingIncomeSourceIsNotSpecified
}


class IncomeSourceEditViewModel {
    private let incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    
    private var incomeSource: IncomeSource? = nil
    
    var name: String? {
        return incomeSource?.name
    }
    
    var selectedCurrency: Currency? = nil
    
    var selectedCurrencyName: String? {
        return selectedCurrency?.translatedName
    }
    
    var selectedCurrencyCode: String? {
        return selectedCurrency?.code
    }
    
    var isNew: Bool {
        return incomeSource == nil
    }
    
    init(incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol) {
        self.incomeSourcesCoordinator = incomeSourcesCoordinator
        self.accountCoordinator = accountCoordinator        
    }
    
    func set(incomeSource: IncomeSource) {
        self.incomeSource = incomeSource
        selectedCurrency = incomeSource.currency
    }
    
    func loadDefaultCurrency() -> Promise<Void> {
        return  firstly {
                    accountCoordinator.loadCurrentUser()
                }.done { user in
                    self.selectedCurrency = user.currency
                }
    }
    
    func isFormValid(with name: String?) -> Bool {
        return isNew ? isCreationFormValid(with: name) : isUpdatingFormValid(with: name)
    }
    
    func saveIncomeSource(with name: String?) -> Promise<Void> {
        return isNew ? createIncomeSource(with: name) : updateIncomeSource(with: name)
    }
    
    func removeIncomeSource(deleteTransactions: Bool) -> Promise<Void> {
        guard let incomeSourceId = incomeSource?.id else {
            return Promise(error: IncomeSourceUpdatingError.updatingIncomeSourceIsNotSpecified)
        }
        return incomeSourcesCoordinator.destroy(by: incomeSourceId, deleteTransactions: deleteTransactions)
    }
    
    private func isCreationFormValid(with name: String?) -> Bool {
        return validateCreation(with: name) == nil
    }
    
    private func isUpdatingFormValid(with name: String?) -> Bool {
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
    
    private func validateCreationForm(with name: String?) -> Promise<IncomeSourceCreationForm> {
        
        if let failureResultsHash = validateCreation(with: name) {
            return Promise(error: IncomeSourceCreationError.validation(validationResults: failureResultsHash))
        }
        
        guard let currentUserId = accountCoordinator.currentSession?.userId else {
            return Promise(error: IncomeSourceCreationError.currentSessionDoesNotExist)
        }
        
        guard let currencyCode = selectedCurrencyCode else {
            return Promise(error: IncomeSourceCreationError.currencyIsNotSpecified)
        }
        
        return .value(IncomeSourceCreationForm(userId: currentUserId,
                                               name: name!,
                                               currency: currencyCode))
    }
    
    private func validateUpdatingForm(with name: String?) -> Promise<IncomeSourceUpdatingForm> {
        
        if let failureResultsHash = validateUpdating(with: name) {
            return Promise(error: IncomeSourceUpdatingError.validation(validationResults: failureResultsHash))
        }
        
        guard let incomeSourceId = incomeSource?.id else {
            return Promise(error: IncomeSourceUpdatingError.updatingIncomeSourceIsNotSpecified)
        }
        
        return .value(IncomeSourceUpdatingForm(id: incomeSourceId,
                                               name: name!))
    }
    
    private func validateCreation(with name: String?) -> [IncomeSourceCreationForm.CodingKeys : [ValidationErrorReason]]? {
        let validationResults : [ValidationResultProtocol] =
            [Validator.validate(required: name, key: IncomeSourceCreationForm.CodingKeys.name)]
        
        let failureResultsHash : [IncomeSourceCreationForm.CodingKeys : [ValidationErrorReason]]? = Validator.failureResultsHash(from: validationResults)
        
        return failureResultsHash
    }
    
    private func validateUpdating(with name: String?) -> [IncomeSourceUpdatingForm.CodingKeys : [ValidationErrorReason]]? {
        
        let validationResults : [ValidationResultProtocol] =
            [Validator.validate(required: name, key: IncomeSourceUpdatingForm.CodingKeys.name)]
        
        let failureResultsHash : [IncomeSourceUpdatingForm.CodingKeys : [ValidationErrorReason]]? = Validator.failureResultsHash(from: validationResults)
        
        return failureResultsHash
    }
}
