//
//  ForgotPasswordViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 05/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

enum ForgotPasswordError : Error {
    case validation(validationResults: [PasswordResetCodeForm.CodingKeys : [ValidationErrorReason]])
}

class ForgotPasswordViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
    }
    
    func createPasswordResetCodeWith(email: String?) -> Promise<PasswordResetCodeForm> {
        return  firstly {
                    validate(email: email)
                }.then { passwordResetCodeForm in
                    self.accountCoordinator.createPasswordResetCode(with: passwordResetCodeForm)
                }
    }
    
    func validate(email: String?) -> Promise<PasswordResetCodeForm> {
        
        let validationResults : [ValidationResultProtocol] =
            [Validator.validate(email: email, key: PasswordResetCodeForm.CodingKeys.email)]
        
        let failureResultsHash : [PasswordResetCodeForm.CodingKeys : [ValidationErrorReason]]? = Validator.failureResultsHash(from: validationResults)
        
        if let failureResultsHash = failureResultsHash {
            return Promise(error: ForgotPasswordError.validation(validationResults: failureResultsHash))
        }
        
        return .value(PasswordResetCodeForm(email: email!))
    }
}
