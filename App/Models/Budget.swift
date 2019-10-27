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
    let incomesAtPeriodCents: Int
    let expenseSourcesAmountCents: Int
    var safeActivesAmountCents: Int
    let riskActivesAmountCents: Int
    let activesAmountCents: Int
        
    enum CodingKeys: String, CodingKey {
        case currency
        case incomesAtPeriodCents = "incomes_at_period_cents"
        case expenseSourcesAmountCents = "expense_sources_amount_cents"
        case safeActivesAmountCents = "safe_actives_amount_cents"
        case riskActivesAmountCents = "risk_actives_amount_cents"
        case activesAmountCents = "actives_amount_cents"
    }
}
