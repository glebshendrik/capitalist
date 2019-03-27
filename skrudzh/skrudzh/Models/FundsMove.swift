//
//  FundsMove.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 07/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation

struct FundsMove : Decodable {
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
    }
    
}

struct FundsMoveCreationForm : Encodable {
    let userId: Int
    let expenseSourceFromId: Int
    let expenseSourceToId: Int
    let amountCents: Int
    let amountCurrency: String
    let convertedAmountCents: Int
    let convertedAmountCurrency: String
    let gotAt: Date
    let comment: String?
    
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
    }
}

struct FundsMoveUpdatingForm : Encodable {
    let id: Int
    let expenseSourceFromId: Int
    let expenseSourceToId: Int
    let amountCents: Int
    let amountCurrency: String
    let convertedAmountCents: Int
    let convertedAmountCurrency: String
    let gotAt: Date
    let comment: String?
    
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
    }
}
