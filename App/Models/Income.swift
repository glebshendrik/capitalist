//
//  Income.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 19/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

struct Income : Decodable {
    let id: Int
    let userId: Int
    let incomeSourceId: Int
    let expenseSourceId: Int
    let incomeSource: IncomeSource
    let expenseSource: ExpenseSource
    let amountCents: Int
    let currency: Currency
    let convertedAmountCents: Int
    let convertedCurrency: Currency
    let gotAt: Date
    let comment: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case incomeSourceId = "income_source_id"
        case expenseSourceId = "expense_source_id"
        case incomeSource = "income_source"
        case expenseSource = "expense_source"
        case amountCents = "amount_cents"
        case currency
        case convertedAmountCents = "converted_amount_cents"
        case convertedCurrency = "converted_currency"
        case gotAt = "got_at"
        case comment
    }
    
}

struct IncomeCreationForm : Encodable, Validatable {
    let userId: Int?
    let incomeSourceId: Int?
    let expenseSourceId: Int?
    let amountCents: Int?
    let amountCurrency: String?
    let convertedAmountCents: Int?
    let convertedAmountCurrency: String?
    let gotAt: Date?
    let comment: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case incomeSourceId = "income_source_id"
        case expenseSourceId = "expense_source_id"
        case amountCents = "amount_cents"
        case amountCurrency = "amount_currency"
        case convertedAmountCents = "converted_amount_cents"
        case convertedAmountCurrency = "converted_amount_currency"
        case gotAt = "got_at"
        case comment
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        
        if !Validator.isValid(present: userId) {
            errors["user_id"] = "Ошибка сохранения"
        }
        
        if !Validator.isValid(present: incomeSourceId) {
            errors["income_source_id"] = "Укажите источник дохода"
        }
        
        if !Validator.isValid(present: expenseSourceId) {
            errors["expense_source_id"] = "Укажите кошелек"
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

struct IncomeUpdatingForm : Encodable, Validatable {
    let id: Int?
    let incomeSourceId: Int?
    let expenseSourceId: Int?
    let amountCents: Int?
    let amountCurrency: String?
    let convertedAmountCents: Int?
    let convertedAmountCurrency: String?
    let gotAt: Date?
    let comment: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case incomeSourceId = "income_source_id"
        case expenseSourceId = "expense_source_id"
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
        
        if !Validator.isValid(present: incomeSourceId) {
            errors["income_source_id"] = "Укажите источник дохода"
        }
        
        if !Validator.isValid(present: expenseSourceId) {
            errors["expense_source_id"] = "Укажите кошелек"
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
