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
    var spentCentsAtPeriod: Int
    let plannedCentsAtPeriod: Int
    
    enum CodingKeys: String, CodingKey {
        case currency
        case balanceCents = "balance_cents"
        case spentCentsAtPeriod = "spent_cents_at_period"
        case plannedCentsAtPeriod = "planned_cents_at_period"
        
    }
}
