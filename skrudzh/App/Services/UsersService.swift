//
//  UsersService.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class UsersService : Service, UsersServiceProtocol {
    
    func createUser(with userForm: UserCreationForm) -> Promise<User> {
        return request(APIResource.createUser(form: userForm))
    }
    
    func updateUser(with userForm: UserUpdatingForm) -> Promise<Void> {
        return request(APIResource.updateUser(form: userForm))
    }
    
    func updateUserSettings(with settingsForm: UserSettingsUpdatingForm) -> Promise<Void> {
        return request(APIResource.updateUserSettings(form: settingsForm))
    }
    
    func changePassword(with changePasswordForm: ChangePasswordForm) -> Promise<Void> {
        return request(APIResource.changePassword(form: changePasswordForm))
    }
    
    func resetPassword(with resetPasswordForm: ResetPasswordForm) -> Promise<Void> {
        return request(APIResource.resetPassword(form: resetPasswordForm))
    }
    
    func createPasswordResetCode(with passwordResetCodeForm: PasswordResetCodeForm) -> Promise<Void> {
        return request(APIResource.createPasswordResetCode(form: passwordResetCodeForm))
    }
    
    func loadUser(with id: Int) -> Promise<User> {
        return request(APIResource.showUser(id: id))
    }
    
    func loadUserBudget(with userId: Int) -> Promise<Budget> {
        return request(APIResource.showBudget(userId: userId))
    }
}
