//
//  ForgotPasswordViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 05/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class ForgotPasswordViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    
    var email: String?
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
    }
    
    func createCode() -> Promise<Void> {
        return accountCoordinator.createPasswordResetCode(with: creationForm()).asVoid()
    }
    
    private func isCreationFormValid() -> Bool {
        return creationForm().validate() == nil
    }
    
    private func creationForm() -> PasswordResetCodeForm {        
        return PasswordResetCodeForm(email: email)
    }
}
