//
//  LoginViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 04/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class LoginViewModel : FieldsViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
    }
    
    func loginWith(email: String?,
                   password: String?) -> Promise<Void> {
        
        clearErrors()
        
        return  firstly {
                    validate(email: email,
                             password: password)
                }.then { sessionCreationForm -> Promise<Session> in
                    self.accountCoordinator.authenticate(with: sessionCreationForm)
                }.asVoid()
                .recover { error in
                    try self.recover(error: error)
                }
    }
    
    func validate(email: String?,
                  password: String?) -> Promise<SessionCreationForm> {
        
        let validationResults : [ValidationResultProtocol] =
            [Validator.validate(email: email, key: SessionCreationForm.CodingKeys.email),
             Validator.validate(password: password, key: SessionCreationForm.CodingKeys.password)]
        
        if let errorPromise : Promise<SessionCreationForm> = validationErrorPromise(for: validationResults) {
            return errorPromise
        }
        
        return .value(SessionCreationForm(email: email,
                                          password: password))
    }
    
    override func validationMessage(for key: CodingKey, reason: ValidationErrorReason) -> String? {
        guard let codingKey = key as? SessionCreationForm.CodingKeys else {
            return nil
        }
        return validationMessageFor(key: codingKey, reason: reason)
    }
    
    private func validationMessageFor(key: SessionCreationForm.CodingKeys, reason: ValidationErrorReason) -> String {
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
        }
    }
}
