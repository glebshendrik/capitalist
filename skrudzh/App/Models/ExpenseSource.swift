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
    let order: Int
    let deletedAt: Date?
    let waitingDebts: [FundsMove]?
    let waitingLoans: [FundsMove]?
    
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
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case amountCurrency = "amount_currency"
        case amountCents = "amount_cents"
        case accountType = "account_type"
        case goalAmountCents = "goal_amount_cents"
    }
    
    init(userId: Int, name: String, amountCents: Int, iconURL: URL?, accountType: AccountType, goalAmountCents: Int?, currency: String) {
        self.userId = userId
        self.name = name
        self.amountCents = amountCents
        self.iconURL = iconURL
        self.accountType = accountType
        self.goalAmountCents = goalAmountCents
        self.amountCurrency = currency
    }
}

struct ExpenseSourceUpdatingForm : Encodable {
    let id: Int
    let name: String
    let amountCents: Int
    let iconURL: URL?
    let goalAmountCents: Int?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case amountCents = "amount_cents"
        case goalAmountCents = "goal_amount_cents"
    }
}

struct ExpenseSourcePositionUpdatingForm : Encodable {
    let id: Int
    let position: Int
    
    enum CodingKeys: String, CodingKey {
        case position = "row_order_position"
    }
}

