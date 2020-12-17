//
//  RegistrationViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 03/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class RegistrationViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    
    var name: String?
    var email: String?
    var password: String?
    var passwordConfirmation: String?
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
    }

    func register() -> Promise<Void> {
        return accountCoordinator.createAndAuthenticateUser(with: creationForm()).asVoid()
    }
    
    private func isCreationFormValid() -> Bool {
        return creationForm().validate() == nil
    }
    
    private func creationForm() -> UserCreationForm {        
        return UserCreationForm(email: email,
                                firstname: name,
                                lastname: "",                                
                                password: password,
                                passwordConfirmation: passwordConfirmation)
    }
}
