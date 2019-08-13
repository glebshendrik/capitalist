//
//  ChangePasswordViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 06/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class ChangePasswordViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    
    var oldPassword: String? = nil
    var newPassword: String? = nil
    var newPasswordConfirmation: String? = nil
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
    }
    
    func resetPassword() -> Promise<Void> {
        return accountCoordinator.changePassword(with: creationForm())
    }
    
    private func isCreationFormValid() -> Bool {
        return creationForm().validate() == nil
    }
    
    private func creationForm() -> ChangePasswordForm {
        return ChangePasswordForm(userId: accountCoordinator.currentSession?.userId,
                                  oldPassword: oldPassword,
                                  newPassword: newPassword,
                                  newPasswordConfirmation: newPasswordConfirmation)
    }
}
