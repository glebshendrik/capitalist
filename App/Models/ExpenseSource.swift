//
//  ExpenseSource.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 25/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation

protocol Validatable {
    func validate() -> [String : String]?
}

struct ExpenseSource : Decodable {
    let id: Int
    let iconURL: URL?
    let name: String
    let amount: String
    var amountCents: Int
    let currency: Currency
    var creditLimitCents: Int?
    let order: Int
    let deletedAt: Date?
    let isVirtual: Bool
    let accountConnection: AccountConnection?
    let prototypeKey: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case iconURL = "icon_url"
        case name
        case amount
        case amountCents = "amount_cents"
        case currency = "currency"
        case creditLimitCents = "credit_limit_cents"
        case order = "row_order"
        case deletedAt = "deleted_at"
        case isVirtual = "is_virtual"
        case accountConnection = "account_connection"
        case prototypeKey = "prototype_key"
    }
}

struct ExpenseSourceCreationForm : Encodable, Validatable {
    var userId: Int?
    let name: String?
    let iconURL: URL?
    let currency: String?
    let amountCents: Int?
    let creditLimitCents: Int?
    let accountConnectionAttributes: AccountConnectionNestedAttributes?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case currency
        case amountCents = "amount_cents"
        case creditLimitCents = "credit_limit_cents"
        case accountConnectionAttributes = "account_connection_attributes"
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: userId) {
            errors["user_id"] = NSLocalizedString("Ошибка сохранения", comment: "Ошибка сохранения")
        }
        
        if !Validator.isValid(required: name) {
            errors[CodingKeys.name.rawValue] = NSLocalizedString("Укажите название", comment: "Укажите название")
        }
        
        if  !Validator.isValid(required: currency) {
            errors[CodingKeys.currency.rawValue] = NSLocalizedString("Укажите валюту", comment: "Укажите валюту")
        }
        
        if !Validator.isValid(balance: amountCents) {
            errors[CodingKeys.amountCents.rawValue] = NSLocalizedString("Укажите текущий баланс", comment: "Укажите текущий баланс")
        }
                
        if !Validator.isValid(money: creditLimitCents) {
            errors[CodingKeys.creditLimitCents.rawValue] = NSLocalizedString("Укажите кредитный лимит (0 по умолчанию)", comment: "Укажите кредитный лимит (0 по умолчанию)")
        }
        
        return errors
    }
}

struct ExpenseSourceUpdatingForm : Encodable, Validatable {
    let id: Int?
    let name: String?
    let iconURL: URL?
    let amountCents: Int?
    let creditLimitCents: Int?
    let accountConnectionAttributes: AccountConnectionNestedAttributes?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case amountCents = "amount_cents"
        case creditLimitCents = "credit_limit_cents"
        case accountConnectionAttributes = "account_connection_attributes"
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: id) {
            errors["id"] = NSLocalizedString("Ошибка сохранения", comment: "Ошибка сохранения")
        }
        
        if !Validator.isValid(required: name) {
            errors[CodingKeys.name.rawValue] = NSLocalizedString("Укажите название", comment: "Укажите название")
        }
        
        if !Validator.isValid(balance: amountCents) {
            errors[CodingKeys.amountCents.rawValue] = NSLocalizedString("Укажите текущий баланс", comment: "Укажите текущий баланс")
        }
                
        if !Validator.isValid(money: creditLimitCents) {
            errors[CodingKeys.creditLimitCents.rawValue] = NSLocalizedString("Укажите кредитный лимит (0 по умолчанию)", comment: "Укажите кредитный лимит (0 по умолчанию)")
        }
        
        return errors
    }
}

struct ExpenseSourcePositionUpdatingForm : Encodable {
    let id: Int
    let position: Int
    
    enum CodingKeys: String, CodingKey {
        case position = "row_order_position"
    }
}

