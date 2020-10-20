//
//  Borrow.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 10/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

enum BorrowType : String, Codable {
    case debt = "Debt"
    case loan = "Loan"
    
    var title: String {
        switch self {
        case .debt:
            return NSLocalizedString("Мне должны", comment: "Мне должны")
        case .loan:
            return NSLocalizedString("Я должен", comment: "Я должен")
        }
    }
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
    let returnedAmountCents: Int
    let borrowingTransactionId: Int?
    
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
        case returnedAmountCents = "returned_amount_cents"
        case borrowingTransactionId = "borrowing_transaction_id"
    }
}

struct BorrowingTransactionNestedAttributes : Encodable {
    let id: Int?
    let sourceId: Int?
    let sourceType: TransactionableType?
    let destinationId: Int?
    let destinationType: TransactionableType?
    
    enum CodingKeys: String, CodingKey {
        case id
        case sourceId = "source_id"
        case sourceType = "source_type"
        case destinationId = "destination_id"
        case destinationType = "destination_type"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let id = id {
            try container.encode(id, forKey: .id)
        }
        
        if let sourceId = sourceId {
            try container.encode(sourceId, forKey: .sourceId)
        }
        
        if let destinationId = destinationId {
            try container.encode(destinationId, forKey: .destinationId)
        }
        
        if let sourceType = sourceType {
            try container.encode(sourceType, forKey: .sourceType)
        }
        
        if let destinationType = destinationType {
            try container.encode(destinationType, forKey: .destinationType)
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
            errors["user_id"] = NSLocalizedString("Ошибка сохранения", comment: "Ошибка сохранения")
        }
        
        if !Validator.isValid(required: name) {
            errors[CodingKeys.name.rawValue] = NSLocalizedString("Укажите название", comment: "Укажите название")
        }
        
        if  !Validator.isValid(required: amountCurrency) {
            errors[CodingKeys.amountCurrency.rawValue] = NSLocalizedString("Укажите валюту", comment: "Укажите валюту")
        }
        
        if !Validator.isValid(positiveMoney: amountCents) {
            errors["amount"] = NSLocalizedString("Укажите сумму", comment: "Укажите сумму")
        }
        
        if !Validator.isValid(pastDate: borrowedAt) {
            errors[CodingKeys.borrowedAt.rawValue] = NSLocalizedString("Укажите дату", comment: "Укажите дату")
        }
                
        if !alreadyOnBalance, let type = type {            
            if type == .debt && !Validator.isValid(present: borrowingTransactionAttributes?.sourceId) {
                errors[BorrowingTransactionNestedAttributes.CodingKeys.sourceId.rawValue] = NSLocalizedString("Укажите кошелек", comment: "Укажите кошелек")
            }
            if type == .loan && !Validator.isValid(present: borrowingTransactionAttributes?.destinationId) {
                errors[BorrowingTransactionNestedAttributes.CodingKeys.destinationId.rawValue] = NSLocalizedString("Укажите кошелек", comment: "Укажите кошелек")
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
    let borrowedAt: Date?
    let payday: Date?
    let comment: String?
    let borrowingTransactionAttributes: BorrowingTransactionNestedAttributes?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case amountCents = "amount_cents"
        case borrowedAt = "borrowed_at"
        case payday
        case comment
        case borrowingTransactionAttributes = "borrowing_transaction_attributes"
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: id) {
            errors["id"] = NSLocalizedString("Ошибка сохранения", comment: "Ошибка сохранения")
        }
        
        if !Validator.isValid(required: name) {
            errors[CodingKeys.name.rawValue] = NSLocalizedString("Укажите название", comment: "Укажите название")
        }
        
        if !Validator.isValid(positiveMoney: amountCents) {
            errors["amount"] = NSLocalizedString("Укажите сумму", comment: "Укажите сумму")
        }
        
        if !Validator.isValid(pastDate: borrowedAt) {
            errors[CodingKeys.borrowedAt.rawValue] = NSLocalizedString("Укажите дату", comment: "Укажите дату")
        }
                
        return errors
    }
}
