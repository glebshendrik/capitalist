//
//  ProfileEditViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 07/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

enum ProfileEditError : Error {
    case validation(validationResults: [UserUpdatingForm.CodingKeys : [ValidationErrorReason]])
    case currentSessionDoesNotExist
}

class ProfileEditViewModel {
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
        return  firstly {
                    validate(firstname: firstname)
                }.then { userUpdatingForm in
                    self.accountCoordinator.updateUser(with: userUpdatingForm)
                }
    }
    
    func validate(firstname: String?) -> Promise<UserUpdatingForm> {
        
        let validationResults : [ValidationResultProtocol] =
            [validate(firstname: firstname)]
        
        let failureResultsHash : [UserUpdatingForm.CodingKeys : [ValidationErrorReason]]? = Validator.failureResultsHash(from: validationResults)
        
        if let failureResultsHash = failureResultsHash {
            return Promise(error: ProfileEditError.validation(validationResults: failureResultsHash))
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
}
