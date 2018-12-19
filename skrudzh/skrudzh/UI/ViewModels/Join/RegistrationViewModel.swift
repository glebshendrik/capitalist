//
//  RegistrationViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 03/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class RegistrationViewModel : FieldsViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    
    private var userCreationForm: UserCreationForm = UserCreationForm.build()
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
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
                    try self.recover(error: error)
                }
    }
    
    private func validate(firstname: String?,
                          email: String?,
                          password: String?,
                          passwordConfirmation: String?) -> Promise<UserCreationForm> {
        
        let validationResults : [ValidationResultProtocol] =
            [Validator.validate(email: email, key: UserCreationForm.CodingKeys.email),
             Validator.validate(password: password, key: UserCreationForm.CodingKeys.password),
             Validator.validate(passwordConfirmation: passwordConfirmation,
                                password: password,
                                passwordConfirmationKey: UserCreationForm.CodingKeys.passwordConfirmation,
                                passwordKey: UserCreationForm.CodingKeys.password)]
        
        if let errorPromise : Promise<UserCreationForm> = validationErrorPromise(for: validationResults) {
            return errorPromise
        }
        
        return .value(UserCreationForm(email: email!,
                                       firstname: firstname,
                                       lastname: "",
                                       password: password!,
                                       passwordConfirmation: passwordConfirmation!))
    }
    
    override func validationMessage(for key: CodingKey, reason: ValidationErrorReason) -> String? {
        guard let codingKey = key as? UserCreationForm.CodingKeys else {
            return nil
        }
        return validationMessageFor(key: codingKey, reason: reason)
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
