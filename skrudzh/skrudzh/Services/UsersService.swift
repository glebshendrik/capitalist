//
//  UsersService.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class UsersService : Service, UsersServiceProtocol {
    
    func createUser(with userForm: UserCreationForm) -> Promise<User> {
        return request(APIResource.createUser(form: userForm))
    }
    
    func createUser(with user: User) -> Promise<User> {
        return request(APIResource.createFulfilledUser(user: user))
    }
    
    func update(user: User) -> Promise<Void> {
        return request(APIResource.updateUser(user: user))
    }
    
    func changePassword(with changePasswordForm: ChangePasswordForm) -> Promise<Void> {
        return request(APIResource.changePassword(form: changePasswordForm))
    }
    
    func resetPassword(with resetPasswordForm: ResetPasswordForm) -> Promise<Void> {
        return request(APIResource.resetPassword(form: resetPasswordForm))
    }
    
    func createConfirmationCode(email: String) -> Promise<Void> {
        return request(APIResource.createConfirmationCode(email: email))
    }
    
    func loadUser(with id: Int) -> Promise<User> {
        return request(APIResource.showUser(id: id))
    }    
}
