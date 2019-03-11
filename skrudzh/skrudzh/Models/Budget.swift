//
//  Budget.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 11/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation

struct Budget : Decodable {
    let currency: Currency
    let balanceCents: Int
    var monthlySpentCents: Int
    let monthlyPlannedCents: Int
    
    
    enum CodingKeys: String, CodingKey {
        case currency
        case balanceCents = "balance_cents"
        case monthlySpentCents = "monthly_spent_cents"
        case monthlyPlannedCents = "monthly_planned_cents"
        
    }
}
