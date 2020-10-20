//
//  ResetPasswordViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 05/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class ResetPasswordViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    
    var email: String?
    var passwordResetCode: String?
    var password: String?
    var passwordConfirmation: String?
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
    }
    
    func resetPassword() -> Promise<Void> {
        return accountCoordinator.resetPassword(with: creationForm()).asVoid()
    }
    
    private func isCreationFormValid() -> Bool {
        return creationForm().validate() == nil
    }
    
    private func creationForm() -> ResetPasswordForm {
        return ResetPasswordForm(email: email,
                                 passwordResetCode: passwordResetCode,
                                 password: password,
                                 passwordConfirmation: passwordConfirmation)
    }
}
