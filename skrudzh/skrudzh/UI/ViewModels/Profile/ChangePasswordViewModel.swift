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
    case currentSessionDoesNotExist
}

class ChangePasswordViewModel : FieldsViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
    }
    
    func changePasswordWith(oldPassword: String?,
                            newPassword: String?,
                            newPasswordConfirmation: String?) -> Promise<Void> {
        
        clearErrors()
        
        return  firstly {
                    validate(oldPassword: oldPassword,
                     newPassword: newPassword,
                     newPasswordConfirmation: newPasswordConfirmation)
                }.then { changePasswordForm in
                    self.accountCoordinator.changePassword(with: changePasswordForm)
                }.recover { error in
                    if case APIRequestError.forbidden = error {
                        let key = ChangePasswordForm.CodingKeys.oldPassword
                        let validationMessage = self.validationMessageFor(key: key,
                                                                          reason: ValidationErrorReason.invalid)
                        self.fieldViewModelBy(codingKey: key)?.set(errors: [validationMessage])
                    }
                    try self.recover(error: error)
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
        
        if let errorPromise : Promise<ChangePasswordForm> = validationErrorPromise(for: validationResults) {
            return errorPromise
        }
        
        guard let currentUserId = accountCoordinator.currentSession?.userId else {
            return Promise(error: ChangePasswordError.currentSessionDoesNotExist)
        }
        
        return .value(ChangePasswordForm(userId: currentUserId,
                                         oldPassword: oldPassword!,
                                         newPassword: newPassword!,
                                         newPasswordConfirmation: newPasswordConfirmation!))
    }
    
    override func validationMessage(for key: CodingKey, reason: ValidationErrorReason) -> String? {
        guard let codingKey = key as? ChangePasswordForm.CodingKeys else {
            return nil
        }
        return validationMessageFor(key: codingKey, reason: reason)
    }
    
    private func validationMessageFor(key: ChangePasswordForm.CodingKeys, reason: ValidationErrorReason) -> String {
        switch (key, reason) {
        case (.oldPassword, .required):
            return "Укажите текущий пароль"
        case (.oldPassword, _):
            return "Некорректный текущий пароль"
        case (.newPassword, .required):
            return "Укажите новый пароль"
        case (.newPassword, _):
            return "Некорректный новый пароль"
        case (.newPasswordConfirmation, .required):
            return "Подтвердите новый пароль"
        case (.newPasswordConfirmation, .notEqual(to: ChangePasswordForm.CodingKeys.newPassword)):
            return "Подтверждение не совпадает с новым паролем"
        case (.newPasswordConfirmation, _):
            return "Некорректное подтверждение нового пароля"
        }
    }
}
