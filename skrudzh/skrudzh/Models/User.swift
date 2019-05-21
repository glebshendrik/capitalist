//
//  User.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
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
    }
}

struct UserUpdatingForm : Encodable {
    let userId: Int
    let firstname: String?
    
    enum CodingKeys: String, CodingKey {
        case firstname
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstname, forKey: .firstname)        
    }
}

struct UserSettingsUpdatingForm : Encodable {
    let userId: Int
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
        case oldPassword = "old_password"
        case newPassword = "new_password"
        case newPasswordConfirmation = "new_password_confirmation"
    }
}

struct ResetPasswordForm : Encodable {
    let email: String
    let passwordResetCode: String
    let password: String
    let passwordConfirmation: String
    
    enum CodingKeys: String, CodingKey {
        case email
        case passwordResetCode = "password_reset_code"
        case password
        case passwordConfirmation = "password_confirmation"
    }    
}

struct PasswordResetCodeForm : Encodable {
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case email
    }
}

