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
    
    func validate(firstname: String?) -> ValidationResult<String?> {
        return .success(key: UserCreationForm.CodingKeys.firstname,
                        value: firstname)
    }
}
