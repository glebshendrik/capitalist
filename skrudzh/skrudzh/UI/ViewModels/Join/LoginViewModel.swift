//
//  LoginViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 04/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

enum LoginError : Error {
    case validation(validationResults: [SessionCreationForm.CodingKeys : [ValidationErrorReason]])
}

class LoginViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
    }
    
    func loginWith(email: String?,
                   password: String?) -> Promise<Void> {
        return  firstly {
                    validate(email: email,
                             password: password)
                }.then { sessionCreationForm -> Promise<Session> in
                    self.accountCoordinator.authenticate(with: sessionCreationForm)
                }.asVoid()
    }
    
    func validate(email: String?,
                  password: String?) -> Promise<SessionCreationForm> {
        
        let validationResults : [ValidationResultProtocol] =            
            [Validator.validate(email: email, key: SessionCreationForm.CodingKeys.email),
             Validator.validate(password: password, key: SessionCreationForm.CodingKeys.password)]
        
        let failureResults = validationResults.filter { !$0.isSucceeded }
        
        guard failureResults.isEmpty else {
            let failureResultsHash: [SessionCreationForm.CodingKeys : [ValidationErrorReason]] =
                failureResults
                    .reduce(into: [:]) { hash, failureResult in
                        
                        if let key = failureResult.key as? SessionCreationForm.CodingKeys {
                            hash[key] = failureResult.failureReasons
                        }
            }
            return Promise(error: LoginError.validation(validationResults: failureResultsHash))
            
        }
        
        return .value(SessionCreationForm(email: email,
                                          password: password))
    }
}
