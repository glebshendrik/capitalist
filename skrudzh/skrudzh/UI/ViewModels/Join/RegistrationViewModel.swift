//
//  RegistrationViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 03/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

enum RegistrationError : Error {
    case validation(validationResults: [UserCreationForm.CodingKeys : [ValidationErrorReason]])
}

class RegistrationViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    
    private var userCreationForm: UserCreationForm = UserCreationForm.build()
    
    public private(set) var fieldViewModels: [FieldViewModel] = []
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
    }
    
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
    
    func registerWith(firstname: String?,
                  email: String?,
                  password: String?,
                  passwordConfirmation: String?) -> Promise<Void> {
        
        clearErrors()
        
        return  firstly {
                    validate(firstname: firstname,
                             email: email,
                             password: password,
                             passwordConfirmation: passwordConfirmation)
                }.get { userCreationForm in
                    self.userCreationForm = userCreationForm
                }.then { userCreationForm -> Promise<Session> in
                    self.accountCoordinator.createAndAuthenticateUser(with: userCreationForm)
                }.asVoid()
                .recover { error in
                    switch error {
                    case RegistrationError.validation(let validationResults):
                        self.addClientValidationErrors(validationResults)
                    case APIRequestError.unprocessedEntity(let errors):
                        self.addRemoteValidationErrors(errors)
                    default:
                        break
                    }
                    throw error
                }
    }
    
    private func clearErrors() {
        fieldViewModels.forEach { $0.removeErrors() }
    }
    
    private func validate(firstname: String?,
                          email: String?,
                          password: String?,
                          passwordConfirmation: String?) -> Promise<UserCreationForm> {
        
        let validationResults : [ValidationResultProtocol] =
            [validate(firstname: firstname),
             Validator.validate(email: email, key: UserCreationForm.CodingKeys.email),
             Validator.validate(password: password, key: UserCreationForm.CodingKeys.password),
             Validator.validate(passwordConfirmation: passwordConfirmation,
                                password: password,
                                passwordConfirmationKey: UserCreationForm.CodingKeys.passwordConfirmation,
                                passwordKey: UserCreationForm.CodingKeys.password)]
        
        let failureResultsHash : [UserCreationForm.CodingKeys : [ValidationErrorReason]]? = Validator.failureResultsHash(from: validationResults)
        
        if let failureResultsHash = failureResultsHash {
            return Promise(error: RegistrationError.validation(validationResults: failureResultsHash))
        }
                
        return .value(UserCreationForm(email: email!,
                                       firstname: firstname,
                                       lastname: "",
                                       password: password!,
                                       passwordConfirmation: passwordConfirmation!))
    }
    
    private func validate(firstname: String?) -> ValidationResult<String?> {
        return .success(key: UserCreationForm.CodingKeys.firstname,
                        value: firstname)
    }
    
    private func addRemoteValidationErrors(_ errors: [String: String]) {
        for (attributeName, validationMessage) in errors {
            if let fieldViewModel = fieldViewModelBy(name: attributeName) {
                fieldViewModel.set(errors: [validationMessage])
            }
        }
    }
    
    private func addClientValidationErrors(_ validationResults: [UserCreationForm.CodingKeys: [ValidationErrorReason]]) {
        
        for (key, reasons) in validationResults {
            if let fieldViewModel = fieldViewModelBy(codingKey: key) {
                let errors = reasons.map { validationMessageFor(key: key, reason: $0) }
                fieldViewModel.set(errors: errors)
            }
        }
    }
    
    private func validationMessageFor(key: UserCreationForm.CodingKeys, reason: ValidationErrorReason) -> String {
        switch (key, reason) {
        case (.email, .required):
            return "Укажите Email"
        case (.email, .invalid):
            return "Некорректный Email"
        case (.email, _):
            return "Некорректный Email"
        case (.password, .required):
            return "Укажите пароль"
        case (.password, _):
            return "Некорректный пароль"
        case (.passwordConfirmation, .required):
            return "Подтвердите пароль"
        case (.passwordConfirmation, .notEqual(to: UserCreationForm.CodingKeys.password)):
            return "Подтверждение не совпадает с паролем"
        case (.passwordConfirmation, _):
            return "Некорректное подтверждение пароля"
        case (_, _):
            return "Ошибка ввода"
        }
    }
}
