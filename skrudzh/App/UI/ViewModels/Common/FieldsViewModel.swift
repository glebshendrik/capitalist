//
//  FieldsViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 19/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class FieldsViewModel {
    public private(set) var fieldViewModels: [FieldViewModel] = []
    
    func register(_ field: Field, attributeName: String, codingKey: CodingKey) {
        fieldViewModels.append(FieldViewModel(field: field,
                                              attributeName: attributeName,
                                              codingKey: codingKey))
    }
    
    func fieldViewModelBy(field: Field) -> FieldViewModel? {
        return fieldViewModels.first { $0.field.fieldId == field.fieldId }
    }
    
    func fieldViewModelBy(name: String) -> FieldViewModel? {
        return fieldViewModels.first { $0.attributeName == name }
    }
    
    func fieldViewModelBy(codingKey: CodingKey) -> FieldViewModel? {
        return fieldViewModels.first { $0.codingKey.stringValue == codingKey.stringValue }
    }
    
    func clearErrors() {
        fieldViewModels.forEach { $0.removeErrors() }
    }
            
    func validationMessage(for key: CodingKey, reason: ValidationErrorReason) -> String? {
        return nil
    }
    
    func recover(error: Error) throws {
        switch error {
        case ValidationError.invalid(let failures):
            self.addClientValidationErrors(failures)
        case APIRequestError.unprocessedEntity(let errors):
            self.addRemoteValidationErrors(errors)
        default:
            break
        }
        throw error
    }
    
    func validationErrorPromise<T>(for validationResults: [ValidationResultProtocol]) -> Promise<T>? {
        guard let failureResults = failures(of: validationResults) else {
            return nil
        }
        return Promise(error: ValidationError.invalid(failures: failureResults))
    }
    
    private func failures(of validationResults: [ValidationResultProtocol]) -> [ValidationResultProtocol]? {
        let failureResults = validationResults.filter { !$0.isSucceeded }
        return failureResults.isEmpty ? nil : failureResults
    }
    
    private func addRemoteValidationErrors(_ errors: [String: String]) {
        for (attributeName, validationMessage) in errors {
            if let fieldViewModel = fieldViewModelBy(name: attributeName) {
                fieldViewModel.set(errors: [validationMessage])
            }
        }
    }
    
    private func addClientValidationErrors(_ failures: [ValidationResultProtocol]) {
        for failure in failures {
            if let fieldViewModel = fieldViewModelBy(codingKey: failure.key) {
                let errors = failure.failureReasons.compactMap { validationMessage(for: failure.key, reason: $0) }
                fieldViewModel.set(errors: errors)
            }
        }
    }
}
