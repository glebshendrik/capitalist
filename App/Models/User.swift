//
//  User.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation

enum AccountingPeriod : String, Codable {
    case week
    case month
    case quarter
    case year
    
    var title: String {
        switch self {
        case .week:
            return "Неделя"
        case .month:
            return "Месяц"
        case .quarter:
            return "Квартал"
        case .year:
            return "Год"
        }
    }
}

struct User : Decodable {
    let id: Int
    let email: String
    let firstname: String?
    let lastname: String?
    let guest: Bool
    let registrationConfirmed: Bool
    let joyBasketId: Int
    let riskBasketId: Int
    let safeBasketId: Int
    let currency: Currency
    let defaultPeriod: AccountingPeriod
    let saltEdgeCustomerSecret: String?
    let minVersion: String?
    let minBuild: String?
    
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
        case joyBasketId = "joy_basket_id"
        case riskBasketId = "risk_basket_id"
        case safeBasketId = "safe_basket_id"
        case currency = "default_currency"
        case defaultPeriod = "default_period"
        case saltEdgeCustomerSecret = "salt_edge_customer_secret"
        case minVersion = "ios_min_version"
        case minBuild = "ios_min_build"
    }
}

extension User {
    var saltEdgeIdentifier: String {
        #if DEBUG
        return "3b_staging_user_\(id)"
        #else
        return "3b_production_user_\(id)"
        #endif
    }
}

struct UserUpdatingForm : Encodable, Validatable {
    let userId: Int?
    let firstname: String?
    let saltEdgeCustomerSecret: String?
    
    init(userId: Int?, firstname: String?) {
        self.init(userId: userId, firstname: firstname, saltEdgeCustomerSecret: nil)
    }
    
    init(userId: Int?, firstname: String?, saltEdgeCustomerSecret: String?) {
        self.userId = userId
        self.firstname = firstname
        self.saltEdgeCustomerSecret = saltEdgeCustomerSecret
    }
    
    enum CodingKeys: String, CodingKey {
        case firstname
        case saltEdgeCustomerSecret = "salt_edge_customer_secret"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let firstname = firstname {
            try container.encode(firstname, forKey: .firstname)
        }
        if let saltEdgeCustomerSecret = saltEdgeCustomerSecret {
            try container.encode(saltEdgeCustomerSecret, forKey: .saltEdgeCustomerSecret)
        }        
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: userId) {
            errors["id"] = "Ошибка сохранения"
        }
        
        return errors
    }
}

struct UserSettingsUpdatingForm : Encodable {
    let userId: Int?
    let currency: String?
    let defaultPeriod: AccountingPeriod?
    
    enum CodingKeys: String, CodingKey {
        case currency = "default_currency"
        case defaultPeriod = "default_period"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let currency = currency {
            try container.encode(currency, forKey: .currency)
        }
        if let defaultPeriod = defaultPeriod {
            try container.encode(defaultPeriod, forKey: .defaultPeriod)
        }
        
    }
}

struct UserDeviceTokenUpdatingForm : Encodable {
    let userId: Int
    let token: String
    
    enum CodingKeys: String, CodingKey {
        case token = "device_token"
    }    
}

struct UserCreationForm : Encodable, Validatable {
    var email: String?
    var firstname: String?
    let lastname: String?
    let password: String?
    let passwordConfirmation: String?
    
    enum CodingKeys: String, CodingKey {
        case email
        case firstname
        case lastname
        case password
        case passwordConfirmation = "password_confirmation"        
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(email: email) {
            errors[CodingKeys.email.rawValue] = "Введите корректный email"
        }
        
        if !Validator.isValid(password: password) {
            errors[CodingKeys.password.rawValue] = "Введите корректный пароль"
        }
        
        if !Validator.isValid(passwordConfirmation: passwordConfirmation,
                              password: password) {
            errors[CodingKeys.passwordConfirmation.rawValue] = "Пароли не совпадают"
        }
        
        return errors
    }
}

struct ChangePasswordForm : Encodable, Validatable {
    let userId: Int?
    let oldPassword: String?
    let newPassword: String?
    let newPasswordConfirmation: String?
    
    enum CodingKeys: String, CodingKey {
        case oldPassword = "old_password"
        case newPassword = "new_password"
        case newPasswordConfirmation = "new_password_confirmation"
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: userId) {
            errors["user_id"] = "Ошибка сохранения"
        }
        
        if !Validator.isValid(password: oldPassword) {
            errors[CodingKeys.oldPassword.rawValue] = "Введите старый пароль"
        }
        
        if !Validator.isValid(password: newPassword) {
            errors[CodingKeys.newPassword.rawValue] = "Введите новый пароль"
        }
        
        if !Validator.isValid(passwordConfirmation: newPasswordConfirmation,
                              password: newPassword) {
            errors[CodingKeys.newPasswordConfirmation.rawValue] = "Пароли не совпадают"
        }
        
        return errors
    }
}

struct ResetPasswordForm : Encodable, Validatable {
    let email: String?
    let passwordResetCode: String?
    let password: String?
    let passwordConfirmation: String?
    
    enum CodingKeys: String, CodingKey {
        case email
        case passwordResetCode = "password_reset_code"
        case password
        case passwordConfirmation = "password_confirmation"
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(email: email) {
            errors[CodingKeys.email.rawValue] = "Укажите email"
        }
        
        if !Validator.isValid(required: passwordResetCode) {
            errors[CodingKeys.passwordResetCode.rawValue] = "Введите код подтверждения"
        }
        
        if !Validator.isValid(password: password) {
            errors[CodingKeys.password.rawValue] = "Введите новый пароль"
        }
        
        if !Validator.isValid(passwordConfirmation: passwordConfirmation,
                              password: password) {
            errors[CodingKeys.passwordConfirmation.rawValue] = "Пароли не совпадают"
        }
        
        return errors
    }
}

struct PasswordResetCodeForm : Encodable, Validatable {
    let email: String?
    
    enum CodingKeys: String, CodingKey {
        case email
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(email: email) {
            errors[CodingKeys.email.rawValue] = "Введите корректный email"
        }
                
        return errors
    }
}

