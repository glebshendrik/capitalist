//
//  Budget.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 11/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

struct Budget : Decodable {
    let currency: Currency
    let incomesAtPeriodCents: Int
    let incomesPlannedAtPeriodCents: Int
    let expenseSourcesAmountCents: Int
    var safeActivesAmountCents: Int
    let riskActivesAmountCents: Int
    let activesAmountCents: Int
    let expensesAtPeriodCents: Int
    let expensesPlannedAtPeriodCents: Int
    
    enum CodingKeys: String, CodingKey {
        case currency
        case incomesAtPeriodCents = "incomes_at_period_cents"
        case incomesPlannedAtPeriodCents = "incomes_planned_at_period_cents"
        case expenseSourcesAmountCents = "expense_sources_amount_cents"
        case safeActivesAmountCents = "safe_actives_amount_cents"
        case riskActivesAmountCents = "risk_actives_amount_cents"
        case activesAmountCents = "actives_amount_cents"
        case expensesAtPeriodCents = "expenses_at_period_cents"
        case expensesPlannedAtPeriodCents = "expenses_planned_at_period_cents"
    }
}
