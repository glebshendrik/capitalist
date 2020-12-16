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
        return request(APIRoute.createUser(form: userForm))
    }
    
    func updateUser(with userForm: UserUpdatingForm) -> Promise<Void> {
        return request(APIRoute.updateUser(form: userForm))
    }
    
    func updateUserSettings(with settingsForm: UserSettingsUpdatingForm) -> Promise<Void> {
        return request(APIRoute.updateUserSettings(form: settingsForm))
    }
    
    func updateUserSubscription(with subscriptionForm: UserSubscriptionUpdatingForm) -> Promise<Void> {
        return request(APIRoute.updateUserSubscription(form: subscriptionForm))
    }
    
    func changePassword(with changePasswordForm: ChangePasswordForm) -> Promise<Void> {
        return request(APIRoute.changePassword(form: changePasswordForm))
    }
    
    func resetPassword(with resetPasswordForm: ResetPasswordForm) -> Promise<Void> {
        return request(APIRoute.resetPassword(form: resetPasswordForm))
    }
    
    func createPasswordResetCode(with passwordResetCodeForm: PasswordResetCodeForm) -> Promise<Void> {
        return request(APIRoute.createPasswordResetCode(form: passwordResetCodeForm))
    }
    
    func loadUser(with id: Int) -> Promise<User> {
        return request(APIRoute.showUser(id: id))
    }
    
    func loadUserBudget(with userId: Int) -> Promise<Budget> {
        return request(APIRoute.showBudget(userId: userId))
    }
    
    func onboardUser(with id: Int) -> Promise<Void> {
        return request(APIRoute.onboardUser(id: id))
    }
    
    func destroyUserData(by id: Int) -> Promise<Void> {
        return request(APIRoute.destroyUserData(id: id))
    }
}
