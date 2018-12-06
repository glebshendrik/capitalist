//
//  ChangePasswordViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 06/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

enum ChangePasswordError : Error {
    case validation(validationResults: [ChangePasswordForm.CodingKeys : [ValidationErrorReason]])
    case currentSessionDoesNotExist
}

class ChangePasswordViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
    }
    
    func changePasswordWith(oldPassword: String?,
                            newPassword: String?,
                            newPasswordConfirmation: String?) -> Promise<Void> {
        return  firstly {
            validate(oldPassword: oldPassword,
                     newPassword: newPassword,
                     newPasswordConfirmation: newPasswordConfirmation)
            }.then { changePasswordForm in
                self.accountCoordinator.changePassword(with: changePasswordForm)
        }
    }
    
    func validate(oldPassword: String?,
                  newPassword: String?,
                  newPasswordConfirmation: String?) -> Promise<ChangePasswordForm> {
        
        let validationResults : [ValidationResultProtocol] =
            [Validator.validate(password: oldPassword, key: ChangePasswordForm.CodingKeys.oldPassword),
             Validator.validate(password: newPassword, key: ChangePasswordForm.CodingKeys.newPassword),
             Validator.validate(passwordConfirmation: newPasswordConfirmation,
                                password: newPassword,
                                passwordConfirmationKey: ChangePasswordForm.CodingKeys.newPasswordConfirmation,
                                passwordKey: ChangePasswordForm.CodingKeys.newPassword)]
        
        let failureResultsHash : [ChangePasswordForm.CodingKeys : [ValidationErrorReason]]? = Validator.failureResultsHash(from: validationResults)
        
        if let failureResultsHash = failureResultsHash {
            return Promise(error: ChangePasswordError.validation(validationResults: failureResultsHash))
        }
        
        guard let currentUserId = accountCoordinator.currentSession?.userId else {
            return Promise(error: ChangePasswordError.currentSessionDoesNotExist)
        }
        
        return .value(ChangePasswordForm(userId: currentUserId,
                                         oldPassword: oldPassword!,
                                         newPassword: newPassword!,
                                         newPasswordConfirmation: newPasswordConfirmation!))
    }
    
    
}
