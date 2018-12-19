//
//  ForgotPasswordViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 05/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class ForgotPasswordViewModel : FieldsViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
    }
    
    func createPasswordResetCodeWith(email: String?) -> Promise<Void> {
        
        clearErrors()
        
        return  firstly {
                    validate(email: email)
                }.then { passwordResetCodeForm in
                    self.accountCoordinator.createPasswordResetCode(with: passwordResetCodeForm)
                }.recover { error in
                    if case APIRequestError.notFound = error {
                        self.fieldViewModelBy(codingKey: PasswordResetCodeForm.CodingKeys.email)?.set(errors: ["Пользователь с таким адресом не найден"])                    
                    }
                    try self.recover(error: error)
                }
    }
    
    func validate(email: String?) -> Promise<PasswordResetCodeForm> {
        
        let validationResults : [ValidationResultProtocol] =
            [Validator.validate(email: email, key: PasswordResetCodeForm.CodingKeys.email)]
        
        if let errorPromise : Promise<PasswordResetCodeForm> = validationErrorPromise(for: validationResults) {
            return errorPromise
        }
        
        return .value(PasswordResetCodeForm(email: email!))
    }
    
    override func validationMessage(for key: CodingKey, reason: ValidationErrorReason) -> String? {
        guard let codingKey = key as? PasswordResetCodeForm.CodingKeys else {
            return nil
        }
        return validationMessageFor(key: codingKey, reason: reason)
    }
    
    private func validationMessageFor(key: PasswordResetCodeForm.CodingKeys, reason: ValidationErrorReason) -> String {
        switch (key, reason) {
        case (.email, .required):
            return "Укажите Email"
        case (.email, _):
            return "Некорректный Email"
        }
    }
}
