//
//  ExpenseSource.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 25/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation

enum AccountType : String, Codable {
    case usual
    case goal
    case debt
}

struct ExpenseSource : Decodable {
    let id: Int
    let name: String
    let amountCurrency: String
    let amount: String
    let amountCents: Int
    let currency: Currency
    let iconURL: URL?
    let accountType: AccountType
    let goalAmountCents: Int?
    let creditLimitCents: Int?
    let order: Int
    let deletedAt: Date?
    let waitingDebts: [FundsMove]?
    let waitingLoans: [FundsMove]?
    let accountConnection: AccountConnection?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case amountCurrency = "amount_currency"
        case amount
        case amountCents = "amount_cents"
        case iconURL = "icon_url"
        case accountType = "account_type"
        case goalAmountCents = "goal_amount_cents"
        case order = "row_order"
        case currency = "currency"
        case deletedAt = "deleted_at"
        case waitingDebts = "waiting_debts"
        case waitingLoans = "waiting_loans"
        case creditLimitCents = "credit_limit_cents"
        case accountConnection = "account_connection"
    }
    
}

struct ExpenseSourceCreationForm : Encodable {
    let userId: Int
    let name: String
    let iconURL: URL?
    let amountCurrency: String
    let amountCents: Int
    let accountType: AccountType
    let goalAmountCents: Int?
    let goalAmountCurrency: String
    let creditLimitCents: Int?
    let creditLimitCurrency: String
    let accountConnectionAttributes: AccountConnectionNestedAttributes?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case amountCurrency = "amount_currency"
        case amountCents = "amount_cents"
        case accountType = "account_type"
        case goalAmountCents = "goal_amount_cents"
        case goalAmountCurrency = "goal_amount_currency"
        case creditLimitCents = "credit_limit_cents"
        case creditLimitCurrency = "credit_limit_currency"
        case accountConnectionAttributes = "account_connection_attributes"
    }
}

struct ExpenseSourceUpdatingForm : Encodable {
    let id: Int
    let name: String
    let amountCents: Int
    let iconURL: URL?
    let goalAmountCents: Int?
    let creditLimitCents: Int?
    let accountConnectionAttributes: AccountConnectionNestedAttributes?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case amountCents = "amount_cents"
        case goalAmountCents = "goal_amount_cents"
        case creditLimitCents = "credit_limit_cents"
        case accountConnectionAttributes = "account_connection_attributes"
    }
}

struct ExpenseSourcePositionUpdatingForm : Encodable {
    let id: Int
    let position: Int
    
    enum CodingKeys: String, CodingKey {
        case position = "row_order_position"
    }
}

