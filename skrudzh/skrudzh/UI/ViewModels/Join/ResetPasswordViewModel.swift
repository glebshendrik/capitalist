//
//  ResetPasswordViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 05/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

enum ResetPasswordError : Error {
    case validation(validationResults: [ResetPasswordForm.CodingKeys : [ValidationErrorReason]])
    case emailInvalid
}

class ResetPasswordViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
    }
    
    func resetPasswordWith(email: String?,
                           passwordResetCode: String?,
                           password: String?,
                           passwordConfirmation: String?) -> Promise<Void> {
        return  firstly {
                    validate(email: email,
                             passwordResetCode: passwordResetCode,
                             password: password,
                             passwordConfirmation: passwordConfirmation)
                }.then { resetPasswordForm in
                    self.accountCoordinator.resetPassword(with: resetPasswordForm)
                }
    }
    
    func validate(email: String?,
                  passwordResetCode: String?,
                  password: String?,
                  passwordConfirmation: String?) -> Promise<ResetPasswordForm> {
        
        guard let email = email, !email.isEmpty else {
            return Promise(error: ResetPasswordError.emailInvalid)
        }
        
        let validationResults : [ValidationResultProtocol] =
            [Validator.validate(required: passwordResetCode, key: ResetPasswordForm.CodingKeys.passwordResetCode),
             Validator.validate(password: password, key: ResetPasswordForm.CodingKeys.password),
             Validator.validate(passwordConfirmation: passwordConfirmation,
                                password: password,
                                passwordConfirmationKey: ResetPasswordForm.CodingKeys.passwordConfirmation,
                                passwordKey: ResetPasswordForm.CodingKeys.password)]
        let failureResultsHash : [ResetPasswordForm.CodingKeys : [ValidationErrorReason]]? = Validator.failureResultsHash(from: validationResults)
        
        if let failureResultsHash = failureResultsHash {
            return Promise(error: ResetPasswordError.validation(validationResults: failureResultsHash))
        }
        
        return .value(ResetPasswordForm(email: email,
                                        passwordResetCode: passwordResetCode!,
                                        password: password!,
                                        passwordConfirmation: passwordConfirmation!))
    }
    
    
}
