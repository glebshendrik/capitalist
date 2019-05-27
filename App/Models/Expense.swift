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

struct ExpenseCreationForm : Encodable {
    let userId: Int
    let expenseSourceId: Int
    let expenseCategoryId: Int
    let amountCents: Int
    let amountCurrency: String
    let convertedAmountCents: Int
    let convertedAmountCurrency: String
    let gotAt: Date
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
}

struct ExpenseUpdatingForm : Encodable {
    let id: Int
    let expenseSourceId: Int
    let expenseCategoryId: Int
    let amountCents: Int
    let amountCurrency: String
    let convertedAmountCents: Int
    let convertedAmountCurrency: String
    let gotAt: Date
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
}
