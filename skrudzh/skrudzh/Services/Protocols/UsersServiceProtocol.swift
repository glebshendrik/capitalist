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
    func createUser(with user: User) -> Promise<User>
    func update(user: User) -> Promise<Void>
    func changePassword(with changePasswordForm: ChangePasswordForm) -> Promise<Void>
    func resetPassword(with resetPasswordForm: ResetPasswordForm) -> Promise<Void>
    func createConfirmationCode(email: String) -> Promise<Void>
    func loadUser(with id: Int) -> Promise<User>
}
