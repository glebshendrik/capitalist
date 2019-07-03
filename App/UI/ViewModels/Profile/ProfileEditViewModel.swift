//
//  ProfileEditViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 07/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum ProfileEditError : Error {
    case currentSessionDoesNotExist
}

class ProfileEditViewModel : FieldsViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    
    private var user: User? = nil
    
    var firstname: String? {
        return user?.firstname
    }
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
    }
    
    func set(user: User?) {
        self.user = user
    }
    
    func updateProfileWith(firstname: String?) -> Promise<Void> {
        
        clearErrors()
        
        return  firstly {
                    validate(firstname: firstname)
                }.then { userUpdatingForm in
                    self.accountCoordinator.updateUser(with: userUpdatingForm)
                }.recover { error in
                    try self.recover(error: error)
                }
    }
    
    func validate(firstname: String?) -> Promise<UserUpdatingForm> {
        
        let validationResults : [ValidationResultProtocol] =
            [validate(firstname: firstname)]
        
        if let errorPromise : Promise<UserUpdatingForm> = validationErrorPromise(for: validationResults) {
            return errorPromise
        }
        
        guard let currentUserId = accountCoordinator.currentSession?.userId else {
            return Promise(error: ProfileEditError.currentSessionDoesNotExist)
        }
        
        return .value(UserUpdatingForm(userId: currentUserId,
                                       firstname: firstname))
    }
    
    func validate(firstname: String?) -> ValidationResult<String?> {
        return .success(key: UserUpdatingForm.CodingKeys.firstname,
                        value: firstname)
    }
    
    override func validationMessage(for key: CodingKey, reason: ValidationErrorReason) -> String? {
        guard let codingKey = key as? UserUpdatingForm.CodingKeys else {
            return nil
        }
        return validationMessageFor(key: codingKey, reason: reason)
    }
    
    private func validationMessageFor(key: UserUpdatingForm.CodingKeys, reason: ValidationErrorReason) -> String {
        switch (key, reason) {
        case (.firstname, _):
            return "Некорректное имя"
        default:
            return "Ошибка валидации"
        }
    }
}
