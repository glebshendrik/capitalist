//
//  Budget.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 11/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

struct Budget : Decodable {
    let currency: Currency
    let balanceCents: Int
    let expenseSourcesBalanceCents: Int
    let includedInBalanceExpensesCents: Int
    var spentCentsAtPeriod: Int
    let plannedCentsAtPeriod: Int
    
    enum CodingKeys: String, CodingKey {
        case currency
        case balanceCents = "balance_cents"
        case spentCentsAtPeriod = "spent_cents_at_period"
        case plannedCentsAtPeriod = "planned_cents_at_period"
        case expenseSourcesBalanceCents = "expense_sources_balance_cents"
        case includedInBalanceExpensesCents = "included_in_balance_expenses_cents"
    }
}
