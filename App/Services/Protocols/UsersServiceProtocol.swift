//
//  UsersServiceProtocol.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
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
    func updateUserSubscription(with subscriptionForm: UserSubscriptionUpdatingForm) -> Promise<Void>
    func changePassword(with changePasswordForm: ChangePasswordForm) -> Promise<Void>
    func resetPassword(with resetPasswordForm: ResetPasswordForm) -> Promise<Void>
    func createPasswordResetCode(with passwordResetCodeForm: PasswordResetCodeForm) -> Promise<Void>
    func loadUser(with id: Int) -> Promise<User>
    func loadUserBudget(with userId: Int) -> Promise<Budget>
    func onboardUser(with id: Int) -> Promise<Void>
    func destroyUserData(by id: Int) -> Promise<Void>
    func sendConfirmationEmail(by id: Int) -> Promise<Void>
}
