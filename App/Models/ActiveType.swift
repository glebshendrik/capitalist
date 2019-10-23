//
//  ActiveType.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

struct ActiveType : Decodable {
    let id: Int
    let name: String
    let localizedKey: String
    let localizedName: String
    let defaultPlannedIncomeType: ActiveIncomeType?
    let rowOrder: Int
    let deletedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case localizedKey = "localized_key"
        case localizedName = "localized_name"
        case defaultPlannedIncomeType = "default_planned_income_type"
        case rowOrder = "row_order"
        case deletedAt = "deleted_at"
    }
}
