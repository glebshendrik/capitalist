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

enum CardType : String, Codable {
    case visa = "visa"
    case masterCard = "master_card"
    case maestro = "maestro"
    case americanExpress = "american_express"
    case mir = "mir"
    case chinaUnionpay = "china_unionpay"
    case dinersClub = "diners_club"
    case jcb = "jcb"
    case uatp = "uatp"
    
    static var all: [CardType] {
        return [.visa, .masterCard, .maestro, .americanExpress, .mir, .chinaUnionpay, .dinersClub, .jcb, .uatp]
    }
    
    var imageName: String {
        switch self {
        case .visa:
            return "visa_icon"
        case .masterCard:
            return "master_card_icon"
        case .maestro:
            return "maestro_icon"
        case .americanExpress:
            return "american_express_icon"
        case .mir:
            return "mir_icon"
        case .chinaUnionpay:
            return "union_pay_icon"
        case .dinersClub:
            return "diners_club_icon"
        case .jcb:
            return "jcb_icon"
        case .uatp:
            return "uatp_icon"
        }
    }
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
    let cardType: CardType?
    let fetchDataFrom: Date?
    
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
        case accountConnection = "salt_edge_account_connection"
        case prototypeKey = "prototype_key"
        case cardType = "card_type"
        case fetchDataFrom = "fetch_data_from"
    }
}

struct ExpenseSourceCreationForm : Encodable, Validatable {
    var userId: Int?
    let name: String?
    let iconURL: URL?
    let currency: String?
    let amountCents: Int?
    let creditLimitCents: Int?
    let cardType: CardType?
    let accountConnectionAttributes: AccountConnectionNestedAttributes?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case currency
        case amountCents = "amount_cents"
        case creditLimitCents = "credit_limit_cents"
        case cardType = "card_type"
        case accountConnectionAttributes = "account_connection_attributes"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
//        if let id = id {
//            try container.encode(id, forKey: .id)
//        }
        
        try container.encode(name, forKey: .name)
        try container.encode(iconURL, forKey: .iconURL)
        try container.encode(currency, forKey: .currency)
        try container.encode(amountCents, forKey: .amountCents)
        try container.encode(creditLimitCents, forKey: .creditLimitCents)
        try container.encode(cardType, forKey: .cardType)
        try container.encode(accountConnectionAttributes, forKey: .accountConnectionAttributes)
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
    let cardType: CardType?
    let accountConnectionAttributes: AccountConnectionNestedAttributes?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case amountCents = "amount_cents"
        case creditLimitCents = "credit_limit_cents"
        case cardType = "card_type"
        case accountConnectionAttributes = "account_connection_attributes"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
//        if let id = id {
//            try container.encode(id, forKey: .id)
//        }
        
        try container.encode(name, forKey: .name)
        try container.encode(iconURL, forKey: .iconURL)
        try container.encode(amountCents, forKey: .amountCents)
        try container.encode(creditLimitCents, forKey: .creditLimitCents)
        try container.encode(cardType, forKey: .cardType)
        try container.encode(accountConnectionAttributes, forKey: .accountConnectionAttributes)
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

