//
//  User.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation

struct User : Decodable {
    let id: Int
    let email: String
    let firstname: String?
    let lastname: String?
    let guest: Bool
    let registrationConfirmed: Bool
    
    var fullname: String? {
        if let firstname = firstname, !firstname.isEmpty, let lastname = lastname, !lastname.isEmpty {
            return "\(firstname) \(lastname)"
        }
        
        if let firstname = firstname, !firstname.isEmpty {
            return firstname
        }
        
        return nil
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstname
        case lastname
        case guest
        case registrationConfirmed = "registration_confirmed"
    }
}

struct UserUpdatingForm : Encodable {
    let userId: Int
    let firstname: String?
    let lastname: String?
    
    enum CodingKeys: String, CodingKey {
        case firstname
        case lastname
    }
}

struct UserCreationForm : Encodable {
    var email: String
    var firstname: String?
    let lastname: String?
    let password: String
    let passwordConfirmation: String
    
    enum CodingKeys: String, CodingKey {
        case email
        case firstname
        case lastname
        case password
        case passwordConfirmation = "password_confirmation"
    }
    
    static func build() -> UserCreationForm {
        return UserCreationForm(email: "",
                                firstname: "",
                                lastname: "",
                                password: "",
                                passwordConfirmation: "")
    }
}

struct ChangePasswordForm : Encodable {
    let userId: Int
    let oldPassword: String
    let newPassword: String
    let newPasswordConfirmation: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case oldPassword = "old_password"
        case newPassword = "new_password"
        case newPasswordConfirmation = "new_password_confirmation"
    }
}

struct ResetPasswordForm : Encodable {
    let email: String
    let confirmationCode: String
    let newPassword: String
    let newPasswordConfirmation: String
    
    enum CodingKeys: String, CodingKey {
        case email
        case confirmationCode = "password_reset_confirmation_code"
        case newPassword = "new_password"
        case newPasswordConfirmation = "new_password_confirmation"
    }    
}
