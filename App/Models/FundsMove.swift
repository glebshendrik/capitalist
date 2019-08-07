//
//  FundsMove.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 07/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class FundsMove : Decodable {
    let id: Int
    let userId: Int
    let expenseSourceFromId: Int
    let expenseSourceToId: Int
    let expenseSourceFrom: ExpenseSource
    let expenseSourceTo: ExpenseSource
    let amountCents: Int
    let currency: Currency
    let convertedAmountCents: Int
    let convertedCurrency: Currency
    let gotAt: Date
    let comment: String?
    let whom: String?
    let borrowedTill: Date?
    let debtTransaction: FundsMove?
    let isReturned: Bool
    let debtAmountCentsLeft: Int?
    let loanAmountCentsLeft: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case expenseSourceFromId = "expense_source_from_id"
        case expenseSourceToId = "expense_source_to_id"
        case expenseSourceFrom = "expense_source_from"
        case expenseSourceTo = "expense_source_to"
        case amountCents = "amount_cents"
        case currency
        case convertedAmountCents = "converted_amount_cents"
        case convertedCurrency = "converted_currency"
        case gotAt = "got_at"
        case comment
        case borrowedTill = "borrowed_till"
        case whom
        case debtTransaction = "debt_transaction"
        case isReturned = "is_returned"
        case debtAmountCentsLeft = "debt_amount_cents_left"
        case loanAmountCentsLeft = "loan_amount_cents_left"
    }
    
}

struct FundsMoveCreationForm : Encodable, Validatable {
    let userId: Int?
    let expenseSourceFromId: Int?
    let expenseSourceToId: Int?
    let amountCents: Int?
    let amountCurrency: String?
    let convertedAmountCents: Int?
    let convertedAmountCurrency: String?
    let gotAt: Date?
    let comment: String?
    let whom: String?
    let borrowedTill: Date?
    let debtTransactionId: Int?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case expenseSourceFromId = "expense_source_from_id"
        case expenseSourceToId = "expense_source_to_id"
        case amountCents = "amount_cents"
        case amountCurrency = "amount_currency"
        case convertedAmountCents = "converted_amount_cents"
        case convertedAmountCurrency = "converted_amount_currency"
        case gotAt = "got_at"
        case comment
        case borrowedTill = "borrowed_till"
        case whom
        case debtTransactionId = "debt_transaction_id"
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: userId) {
            errors["user_id"] = "Ошибка сохранения"
        }
        
        if !Validator.isValid(present: expenseSourceFromId) {
            errors["expense_source_from_id"] = "Укажите кошелек снятия"
        }
        
        if !Validator.isValid(present: expenseSourceToId) {
            errors["expense_source_to_id"] = "Укажите кошелек пополнения"
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

struct FundsMoveUpdatingForm : Encodable, Validatable {
    let id: Int?
    let expenseSourceFromId: Int?
    let expenseSourceToId: Int?
    let amountCents: Int?
    let amountCurrency: String?
    let convertedAmountCents: Int?
    let convertedAmountCurrency: String?
    let gotAt: Date?
    let comment: String?
    let whom: String?
    let borrowedTill: Date?
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case expenseSourceFromId = "expense_source_from_id"
        case expenseSourceToId = "expense_source_to_id"
        case amountCents = "amount_cents"
        case amountCurrency = "amount_currency"
        case convertedAmountCents = "converted_amount_cents"
        case convertedAmountCurrency = "converted_amount_currency"
        case gotAt = "got_at"
        case comment
        case borrowedTill = "borrowed_till"
        case whom
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: id) {
            errors["id"] = "Ошибка сохранения"
        }
        
        if !Validator.isValid(present: expenseSourceFromId) {
            errors["expense_source_from_id"] = "Укажите кошелек снятия"
        }
        
        if !Validator.isValid(present: expenseSourceToId) {
            errors["expense_source_to_id"] = "Укажите кошелек пополнения"
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

