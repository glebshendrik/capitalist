//
//  ExpenseSource.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 25/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation

struct ExpenseSource : Decodable {
    let id: Int
    let name: String
    let amountCurrency: String
    let amount: String
    let amountCents: Int
    let currency: Currency
    let iconURL: URL?
    let isGoal: Bool
    let goalAmountCents: Int?
    let order: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case amountCurrency = "amount_currency"
        case amount
        case amountCents = "amount_cents"
        case iconURL = "icon_url"
        case isGoal = "is_goal"
        case goalAmountCents = "goal_amount_cents"
        case order = "row_order"
        case currency = "currency"
    }
    
}

struct ExpenseSourceCreationForm : Encodable {
    let userId: Int
    let name: String
    let iconURL: URL?
    let amountCurrency: String
    let amountCents: Int
    let isGoal: Bool
    let goalAmountCents: Int?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case amountCurrency = "amount_currency"
        case amountCents = "amount_cents"
        case isGoal = "is_goal"
        case goalAmountCents = "goal_amount_cents"
    }
    
    init(userId: Int, name: String, amountCents: Int, iconURL: URL?, isGoal: Bool, goalAmountCents: Int?, currency: String) {
        self.userId = userId
        self.name = name
        self.amountCents = amountCents
        self.iconURL = iconURL
        self.isGoal = isGoal
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

