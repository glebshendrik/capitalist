//
//  UsersServiceProtocol.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

enum ResetPasswordFormError: Error {
    case invalidEmail, invalidCredentials
}

protocol UsersServiceProtocol {
    func createUser(with userForm: UserCreationForm) -> Promise<User>
    func updateUser(with userForm: UserUpdatingForm) -> Promise<Void>
    func updateUserSettings(with settingsForm: UserSettingsUpdatingForm) -> Promise<Void>
    func changePassword(with changePasswordForm: ChangePasswordForm) -> Promise<Void>
    func resetPassword(with resetPasswordForm: ResetPasswordForm) -> Promise<Void>
    func createPasswordResetCode(with passwordResetCodeForm: PasswordResetCodeForm) -> Promise<Void>
    func loadUser(with id: Int) -> Promise<User>
    func loadUserBudget(with userId: Int) -> Promise<Budget>
}
