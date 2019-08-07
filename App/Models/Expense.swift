//
//  Expense.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 07/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

struct Expense : Decodable {
    let id: Int
    let userId: Int
    let expenseSourceId: Int
    let expenseCategoryId: Int
    let expenseSource: ExpenseSource
    let expenseCategory: ExpenseCategory
    let amountCents: Int
    let currency: Currency
    let convertedAmountCents: Int
    let convertedCurrency: Currency
    let gotAt: Date
    let comment: String?
    let includedInBalance: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case expenseSourceId = "expense_source_id"
        case expenseCategoryId = "expense_category_id"
        case expenseSource = "expense_source"
        case expenseCategory = "expense_category"
        case amountCents = "amount_cents"
        case currency
        case convertedAmountCents = "converted_amount_cents"
        case convertedCurrency = "converted_currency"
        case gotAt = "got_at"
        case comment
        case includedInBalance = "included_in_balance"
    }
    
}

struct ExpenseCreationForm : Encodable, Validatable {
    let userId: Int?
    let expenseSourceId: Int?
    let expenseCategoryId: Int?
    let amountCents: Int?
    let amountCurrency: String?
    let convertedAmountCents: Int?
    let convertedAmountCurrency: String?
    let gotAt: Date?
    let comment: String?
    let includedInBalance: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case expenseSourceId = "expense_source_id"
        case expenseCategoryId = "expense_category_id"
        case amountCents = "amount_cents"
        case amountCurrency = "amount_currency"
        case convertedAmountCents = "converted_amount_cents"
        case convertedAmountCurrency = "converted_amount_currency"
        case gotAt = "got_at"
        case comment
        case includedInBalance = "included_in_balance"
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: userId) {
            errors["user_id"] = "Ошибка сохранения"
        }
        
        if !Validator.isValid(present: expenseSourceId) {
            errors["expense_source_id"] = "Укажите кошелек"
        }
        
        if !Validator.isValid(present: expenseCategoryId) {
            errors["expense_category_id"] = "Укажите категорию трат"
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

struct ExpenseUpdatingForm : Encodable, Validatable {
    let id: Int?
    let expenseSourceId: Int?
    let expenseCategoryId: Int?
    let amountCents: Int?
    let amountCurrency: String?
    let convertedAmountCents: Int?
    let convertedAmountCurrency: String?
    let gotAt: Date?
    let comment: String?
    let includedInBalance: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case expenseSourceId = "expense_source_id"
        case expenseCategoryId = "expense_category_id"
        case amountCents = "amount_cents"
        case amountCurrency = "amount_currency"
        case convertedAmountCents = "converted_amount_cents"
        case convertedAmountCurrency = "converted_amount_currency"
        case gotAt = "got_at"
        case comment
        case includedInBalance = "included_in_balance"
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: id) {
            errors["id"] = "Ошибка сохранения"
        }
        
        if !Validator.isValid(present: expenseSourceId) {
            errors["expense_source_id"] = "Укажите кошелек"
        }
        
        if !Validator.isValid(present: expenseCategoryId) {
            errors["expense_category_id"] = "Укажите категорию трат"
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
