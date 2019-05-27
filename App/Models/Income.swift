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

struct IncomeCreationForm : Encodable {
    let userId: Int
    let incomeSourceId: Int
    let expenseSourceId: Int
    let amountCents: Int
    let amountCurrency: String
    let convertedAmountCents: Int
    let convertedAmountCurrency: String
    let gotAt: Date
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
}

struct IncomeUpdatingForm : Encodable {
    let id: Int
    let incomeSourceId: Int
    let expenseSourceId: Int
    let amountCents: Int
    let amountCurrency: String
    let convertedAmountCents: Int
    let convertedAmountCurrency: String
    let gotAt: Date
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
}
