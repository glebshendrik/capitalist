//
//  Borrow.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

enum BorrowType : String, Codable {
    case debt = "Debt"
    case loan = "Loan"
}

struct Borrow : Decodable {
    let id: Int
    let type: BorrowType
    let iconURL: URL?
    let name: String
    let amountCents: Int
    let currency: Currency
    let borrowedAt: Date
    let payday: Date?
    let comment: String?
    let isReturned: Bool
    let amountCentsLeft: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case iconURL = "icon_url"
        case name
        case amountCents = "amount_cents"
        case currency
        case borrowedAt = "borrowed_at"
        case payday
        case comment
        case isReturned = "is_returned"
        case amountCentsLeft = "amount_cents_left"
    }
}

struct BorrowingTransactionNestedAttributes : Encodable {
    let expenseSourceFromId: Int?
    let expenseSourceToId: Int?
    
    enum CodingKeys: String, CodingKey {
        case expenseSourceFromId = "expense_source_from_id"
        case expenseSourceToId = "expense_source_to_id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let expenseSourceFromId = expenseSourceFromId {
            try container.encode(expenseSourceFromId, forKey: .expenseSourceFromId)
        }
        
        if let expenseSourceToId = expenseSourceToId {
            try container.encode(expenseSourceToId, forKey: .expenseSourceToId)
        }
    }
}

struct BorrowCreationForm : Encodable, Validatable {
    var userId: Int?
    let type: BorrowType?
    let name: String?
    let iconURL: URL?
    let amountCents: Int?
    let amountCurrency: String?
    let borrowedAt: Date
    let payday: Date?
    let comment: String?
    let alreadyOnBalance: Bool
    let borrowingTransactionAttributes: BorrowingTransactionNestedAttributes?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case amountCents = "amount_cents"
        case amountCurrency = "amount_currency"
        case borrowedAt = "borrowed_at"
        case payday
        case comment
        case borrowingTransactionAttributes = "borrowing_transaction_attributes"
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: userId) {
            errors["user_id"] = "Ошибка сохранения"
        }
        
        if !Validator.isValid(required: name) {
            errors[CodingKeys.name.rawValue] = "Укажите название"
        }
        
        if  !Validator.isValid(required: amountCurrency) {
            errors[CodingKeys.amountCurrency.rawValue] = "Укажите валюту"
        }
        
        if !Validator.isValid(positiveMoney: amountCents) {
            errors[CodingKeys.amountCents.rawValue] = "Укажите сумму"
        }
        
        if !Validator.isValid(pastDate: borrowedAt) {
            errors[CodingKeys.borrowedAt.rawValue] = "Укажите дату"
        }
        
        if !Validator.isValid(futureDate: payday) {
            errors[CodingKeys.payday.rawValue] = "Укажите дату возврата"
        }
        
        if !alreadyOnBalance, let type = type {            
            if type == .debt && !Validator.isValid(present: borrowingTransactionAttributes?.expenseSourceFromId) {
                errors[BorrowingTransactionNestedAttributes.CodingKeys.expenseSourceFromId.rawValue] = "Укажите кошелек"
            }
            if type == .loan && !Validator.isValid(present: borrowingTransactionAttributes?.expenseSourceToId) {
                errors[BorrowingTransactionNestedAttributes.CodingKeys.expenseSourceToId.rawValue] = "Укажите кошелек"
            }
        }
        return errors
    }
}

struct BorrowUpdatingForm : Encodable, Validatable {
    var id: Int?
    let name: String?
    let iconURL: URL?
    let amountCents: Int?
    let borrowedAt: Date
    let payday: Date?
    let comment: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case amountCents = "amount_cents"
        case borrowedAt = "borrowed_at"
        case payday
        case comment
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: id) {
            errors["id"] = "Ошибка сохранения"
        }
        
        if !Validator.isValid(required: name) {
            errors[CodingKeys.name.rawValue] = "Укажите название"
        }
        
        if !Validator.isValid(positiveMoney: amountCents) {
            errors[CodingKeys.amountCents.rawValue] = "Укажите сумму"
        }
        
        if !Validator.isValid(pastDate: borrowedAt) {
            errors[CodingKeys.borrowedAt.rawValue] = "Укажите дату"
        }
        
        if !Validator.isValid(futureDate: payday) {
            errors[CodingKeys.payday.rawValue] = "Укажите дату возврата"
        }
        
        return errors
    }
}
