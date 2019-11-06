//
//  Transaction.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

enum TransactionType : String, Codable {
    case income = "income"
    case expense = "expense"
    case fundsMove = "funds_move"
}

enum TransactionableType : String, Codable {
    case incomeSource = "IncomeSource"
    case expenseSource = "ExpenseSource"
    case expenseCategory = "ExpenseCategory"
    case active = "Active"
}

struct Transaction : Decodable {
    let id: Int
    let userId: Int
    let type: TransactionType
    let sourceId: Int
    let sourceType: TransactionableType
    let destinationId: Int
    let destinationType: TransactionableType
    let sourceTitle: String
    let destinationTitle: String
    let destinationIconURL: URL?
    let currency: Currency
    let amountCents: Int
    let convertedCurrency: Currency
    let convertedAmountCents: Int
    let gotAt: Date
    let comment: String?
    let includedInBalance: Bool? = false
    let basketType: BasketType?
    let whom: String?
    let payday: Date?
    let isReturned: Bool?
    let borrow: Borrow?
    let returningBorrow: Borrow?
    let credit: Credit?
    let isBuyingAsset: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case type = "transaction_type"
        case sourceId = "source_id"
        case sourceType = "source_type"
        case destinationId = "destination_id"
        case destinationType = "destination_type"
        case sourceTitle = "source_title"
        case destinationTitle = "destination_title"
        case destinationIconURL = "destination_icon_url"
        case currency = "amount_currency"
        case amountCents = "amount_cents"
        case convertedCurrency = "converted_amount_currency"
        case convertedAmountCents = "converted_amount_cents"
        case gotAt = "got_at"
        case comment
        case basketType = "basket_type"
        case payday
        case whom
        case isReturned = "is_returned"
        case borrow
        case returningBorrow = "returning_borrow"
        case credit
        case isBuyingAsset = "buying_asset"
    }
    
}

struct TransactionCreationForm : Encodable, Validatable {
    let userId: Int?
    let sourceId: Int?
    let sourceType: TransactionableType?
    let destinationId: Int?
    let destinationType: TransactionableType?
    let amountCents: Int?
    let amountCurrency: String?
    let convertedAmountCents: Int?
    let convertedAmountCurrency: String?
    let gotAt: Date?
    let comment: String?
    let returningBorrowId: Int?
    let isBuyingAsset: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case sourceId = "source_id"
        case sourceType = "source_type"
        case destinationId = "destination_id"
        case destinationType = "destination_type"
        case amountCents = "amount_cents"
        case amountCurrency = "amount_currency"
        case convertedAmountCents = "converted_amount_cents"
        case convertedAmountCurrency = "converted_amount_currency"
        case gotAt = "got_at"
        case comment
        case returningBorrowId = "returning_borrow_id"
        case isBuyingAsset = "buying_asset"
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: userId) {
            errors["user_id"] = "Ошибка сохранения"
        }
        
        if !Validator.isValid(present: sourceId) {
            errors["source_id"] = "Укажите источник"
        }
        
        if !Validator.isValid(present: destinationId) {
            errors["destination_id"] = "Укажите назначение"
        }
        
        if !Validator.isValid(present: amountCurrency) {
            errors["amount_currency"] = "Укажите валюту"
        }
        
        if !Validator.isValid(present: convertedAmountCurrency) {
            errors["converted_amount_currency"] = "Укажите валюту конвертации"
        }
        
        if !Validator.isValid(positiveMoney: amountCents) {
            errors["amount_cents"] = "Укажите сумму списания"
        }
        
        if !Validator.isValid(positiveMoney: convertedAmountCents) {
            errors["converted_amount_cents"] = "Укажите сумму зачисления"
        }
        
        if !Validator.isValid(pastDate: gotAt) {
            errors["got_at"] = "Укажите дату транзакции"
        }
        
        return errors
    }
}

struct TransactionUpdatingForm : Encodable, Validatable {
    let id: Int?
    let sourceId: Int?
    let sourceType: TransactionableType?
    let destinationId: Int?
    let destinationType: TransactionableType?
    let amountCents: Int?
    let amountCurrency: String?
    let convertedAmountCents: Int?
    let convertedAmountCurrency: String?
    let gotAt: Date?
    let comment: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case sourceId = "source_id"
        case sourceType = "source_type"
        case destinationId = "destination_id"
        case destinationType = "destination_type"
        case amountCents = "amount_cents"
        case amountCurrency = "amount_currency"
        case convertedAmountCents = "converted_amount_cents"
        case convertedAmountCurrency = "converted_amount_currency"
        case gotAt = "got_at"
        case comment
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: id) {
            errors["id"] = "Ошибка сохранения"
        }
        
        if !Validator.isValid(present: sourceId) {
            errors["source_id"] = "Укажите источник"
        }
        
        if !Validator.isValid(present: destinationId) {
            errors["destination_id"] = "Укажите назначение"
        }
        
        if !Validator.isValid(present: amountCurrency) {
            errors["amount_currency"] = "Укажите валюту"
        }
        
        if !Validator.isValid(present: convertedAmountCurrency) {
            errors["converted_amount_currency"] = "Укажите валюту конвертации"
        }
        
        if !Validator.isValid(positiveMoney: amountCents) {
            errors["amount_cents"] = "Укажите сумму списания"
        }
        
        if !Validator.isValid(positiveMoney: convertedAmountCents) {
            errors["converted_amount_cents"] = "Укажите сумму зачисления"
        }
        
        if !Validator.isValid(pastDate: gotAt) {
            errors["got_at"] = "Укажите дату транзакции"
        }
        
        return errors
    }
}
