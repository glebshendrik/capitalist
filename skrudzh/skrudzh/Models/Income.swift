//
//  Income.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 19/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation

struct Income : Decodable {
    let id: Int
    let userId: Int
    let incomeSourceId: Int
    let expenseSourceId: Int
    let amountCents: Int
    let currency: Currency
    let gotAt: Date
    let comment: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case incomeSourceId = "income_source_id"
        case expenseSourceId = "expense_source_id"
        case amountCents = "amount_cents"
        case currency
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
    let gotAt: Date
    let comment: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case incomeSourceId = "income_source_id"
        case expenseSourceId = "expense_source_id"
        case amountCents = "amount_cents"
        case amountCurrency = "amount_currency"
        case gotAt = "got_at"
        case comment
    }
}

struct IncomeUpdatingForm : Encodable {
    let id: Int
    let amountCents: Int
    let gotAt: Date
    let comment: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case amountCents = "amount_cents"
        case gotAt = "got_at"
        case comment
    }
}
