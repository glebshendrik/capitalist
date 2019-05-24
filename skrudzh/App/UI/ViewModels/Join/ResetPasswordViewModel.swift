//
//  ResetPasswordViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 05/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class ResetPasswordViewModel : FieldsViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
    }
    
    func resetPasswordWith(email: String?,
                           passwordResetCode: String?,
                           password: String?,
                           passwordConfirmation: String?) -> Promise<Void> {
        
        clearErrors()
        
        return  firstly {
                    validate(email: email,
                             passwordResetCode: passwordResetCode,
                             password: password,
                             passwordConfirmation: passwordConfirmation)
                }.then { resetPasswordForm in
                    self.accountCoordinator.resetPassword(with: resetPasswordForm)
                }.recover { error in                    
                    if case APIRequestError.forbidden = error {
                        self.fieldViewModelBy(codingKey: ResetPasswordForm.CodingKeys.passwordResetCode)?.set(errors: ["Код восстановления неверный или больше не действует"])
                    }
                    try self.recover(error: error)
                }
    }
    
    func validate(email: String?,
                  passwordResetCode: String?,
                  password: String?,
                  passwordConfirmation: String?) -> Promise<ResetPasswordForm> {
        
        let validationResults : [ValidationResultProtocol] =
            [Validator.validate(email: email, key: ResetPasswordForm.CodingKeys.email),
             Validator.validate(required: passwordResetCode, key: ResetPasswordForm.CodingKeys.passwordResetCode),
             Validator.validate(password: password, key: ResetPasswordForm.CodingKeys.password),
             Validator.validate(passwordConfirmation: passwordConfirmation,
                                password: password,
                                passwordConfirmationKey: ResetPasswordForm.CodingKeys.passwordConfirmation,
                                passwordKey: ResetPasswordForm.CodingKeys.password)]
        
        if let errorPromise : Promise<ResetPasswordForm> = validationErrorPromise(for: validationResults) {
            return errorPromise
        }
        
        return .value(ResetPasswordForm(email: email!,
                                        passwordResetCode: passwordResetCode!,
                                        password: password!,
                                        passwordConfirmation: passwordConfirmation!))
    }
    
    override func validationMessage(for key: CodingKey, reason: ValidationErrorReason) -> String? {
        guard let codingKey = key as? ResetPasswordForm.CodingKeys else {
            return nil
        }
        return validationMessageFor(key: codingKey, reason: reason)
    }
    
    private func validationMessageFor(key: ResetPasswordForm.CodingKeys, reason: ValidationErrorReason) -> String {
        switch (key, reason) {
        case (.email, .required):
            return "Укажите Email"
        case (.email, .invalid):
            return "Некорректный Email"
        case (.email, _):
            return "Некорректный Email"
        case (.passwordResetCode, .required):
            return "Укажите код восстановления"
        case (.passwordResetCode, _):
            return "Некорректный код восстановления"
        case (.password, .required):
            return "Укажите пароль"
        case (.password, _):
            return "Некорректный пароль"
        case (.passwordConfirmation, .required):
            return "Подтвердите пароль"
        case (.passwordConfirmation, .notEqual(to: ResetPasswordForm.CodingKeys.password)):
            return "Подтверждение не совпадает с паролем"
        case (.passwordConfirmation, _):
            return "Некорректное изменение пароля"
        }
    }
}
