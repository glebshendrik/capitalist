//
//  Session.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation

struct Session : Decodable {
    let token: String
    let userId: Int
    let joyBasketId: Int
    let riskBasketId: Int
    let safeBasketId: Int

    enum CodingKeys: String, CodingKey {
        case token
        case user
    }
    
    init(token: String, userId: Int, joyBasketId: Int, riskBasketId: Int, safeBasketId: Int) {
        self.token = token
        self.userId = userId
        self.joyBasketId = joyBasketId
        self.riskBasketId = riskBasketId
        self.safeBasketId = safeBasketId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        token = try container.decode(String.self, forKey: .token)
        let user = try container.decode(User.self, forKey: .user)
        userId = user.id
        joyBasketId = user.joyBasketId
        riskBasketId = user.riskBasketId
        safeBasketId = user.safeBasketId        
    }
}

struct SessionCreationForm : Encodable, Validatable {
    let email: String?
    let password: String?
    let skipValidation: Bool
    
    init(email: String?, password: String?, skipValidation: Bool = false) {
        self.email = email
        self.password = password
        self.skipValidation = skipValidation
    }
    
    enum CodingKeys: String, CodingKey {
        case email
        case password
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(email, forKey: .email)
        try container.encode(password, forKey: .password)
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if skipValidation {
            return errors
        }
        
        if !Validator.isValid(email: email) {
            errors["email"] = "Введите корректный email"
        }
        
        if !Validator.isValid(password: password) {
            errors["password"] = "Введите корректный пароль"
        }
        
        return errors
    }
}
