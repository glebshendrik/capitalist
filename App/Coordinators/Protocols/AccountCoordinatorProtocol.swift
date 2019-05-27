//
//  AccountCoordinatorProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol AccountCoordinatorProtocol {
    var currentSession: Session? { get }
    func joinAsGuest() -> Promise<Session>
    func authenticate(with form: SessionCreationForm) -> Promise<Session>
    func createAndAuthenticateUser(with userForm: UserCreationForm) -> Promise<Session>
    func updateUser(with userForm: UserUpdatingForm) -> Promise<Void>
    func changePassword(with changePasswordForm: ChangePasswordForm) -> Promise<Void>
    func resetPassword(with resetPasswordForm: ResetPasswordForm) -> Promise<Void>
    func createPasswordResetCode(with passwordResetCodeForm: PasswordResetCodeForm) -> Promise<Void>
    func loadCurrentUser() -> Promise<User>
    func logout() -> Promise<Void>
    func loadCurrentUserBudget() -> Promise<Budget>
}

