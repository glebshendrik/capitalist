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

enum ValidationErrorReason {
    case required
    case invalid
    case tooShort
    case tooLong
    case notEqual(to: UserCreationForm.CodingKeys)
}

protocol ValidationResultProtocol {
    var isSucceeded: Bool { get }
    var key: CodingKey { get }
    var failureReasons: [ValidationErrorReason] { get }
}

enum ValidationResult<T> {
    case success(key: CodingKey, value: T)
    case failure(key: CodingKey, reasons: [ValidationErrorReason])
    
    var value: T? {
        switch self {
        case .success(_, let value):
            return value
        case .failure:
            return nil
        }
    }
    
}

extension ValidationResult : ValidationResultProtocol {
    var isSucceeded: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    var key: CodingKey {
        switch self {
        case .success(let key, _):
            return key
        case .failure(let key, _):
            return key
        }
    }
    
    var failureReasons: [ValidationErrorReason] {
        switch self {
        case .success:
            return []
        case .failure(_, let reasons):
            return reasons
        }
    }
}

class RegistrationViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    
    private var userCreationForm: UserCreationForm = UserCreationForm.build()
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
    }
    
    func registerWith(firstname: String?,
                  email: String?,
                  password: String?,
                  passwordConfirmation: String?) -> Promise<Void> {
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
    }

    func validate(firstname: String?,
                  email: String?,
                  password: String?,
                  passwordConfirmation: String?) -> Promise<UserCreationForm> {
        
        let validationResults : [ValidationResultProtocol] =
            [validate(firstname: firstname),
             validate(email: email),
             validate(password: password),
             validate(passwordConfirmation: passwordConfirmation, password: password)]
        
        let failureResults = validationResults.filter { !$0.isSucceeded }
        
        guard failureResults.isEmpty else {
            let failureResultsHash: [UserCreationForm.CodingKeys : [ValidationErrorReason]] =
                failureResults
                    .reduce(into: [:]) { hash, failureResult in
                        
                        if let key = failureResult.key as? UserCreationForm.CodingKeys {
                            hash[key] = failureResult.failureReasons
                        }
            }
            return Promise(error: RegistrationError.validation(validationResults: failureResultsHash))
            
        }
        
        return .value(UserCreationForm(email: email!,
                                       firstname: firstname,
                                       lastname: "",
                                       password: password!,
                                       passwordConfirmation: passwordConfirmation!))
    }
    
    func validate(firstname: String?) -> ValidationResult<String?> {
        return .success(key: UserCreationForm.CodingKeys.firstname,
                        value: firstname)
    }
    
    func validate(email: String?) -> ValidationResult<String> {
        guard let email = email, !email.isEmpty else {
            return .failure(key: UserCreationForm.CodingKeys.email,
                            reasons: [ValidationErrorReason.required])
        }
        return .success(key: UserCreationForm.CodingKeys.email,
                        value: email)
    }
    
    func validate(password: String?) -> ValidationResult<String> {
        guard let password = password, !password.isEmpty else {
            return .failure(key: UserCreationForm.CodingKeys.password,
                            reasons: [ValidationErrorReason.required])
        }
        return .success(key: UserCreationForm.CodingKeys.password,
                        value: password)
    }
    
    func validate(passwordConfirmation: String?, password: String?) -> ValidationResult<String> {
        guard let passwordConfirmation = passwordConfirmation, !passwordConfirmation.isEmpty else {
            return .failure(key: UserCreationForm.CodingKeys.passwordConfirmation,
                            reasons: [ValidationErrorReason.required])
        }
        guard password == passwordConfirmation else {
            return .failure(key: UserCreationForm.CodingKeys.passwordConfirmation,
                            reasons: [ValidationErrorReason.notEqual(to: UserCreationForm.CodingKeys.password)])
        }
        return .success(key: UserCreationForm.CodingKeys.passwordConfirmation,
                        value: passwordConfirmation)
    }
    
    
}