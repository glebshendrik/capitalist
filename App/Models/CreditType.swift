//
//  CreditType.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

enum PeriodUnit : String, Codable {
    case days
    case months
    case years
}

struct CreditType : Decodable {
    let id: Int
    let name: String
    let localizedKey: String
    let localizedName: String
    let periodUnit: PeriodUnit
    let minValue: Int
    let maxValue: Int
    let defaultValue: Int
    let hasMonthlyPayments: Bool
    let periodSuperUnit: PeriodUnit?
    let unitsInSuperUnit: Int?
    let rowOrder: Int
    let deletedAt: Date?
    let isDefault: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case localizedKey = "localized_key"
        case localizedName = "localized_name"
        case periodUnit = "period_unit"
        case minValue = "min_value"
        case maxValue = "max_value"
        case defaultValue = "default_value"
        case hasMonthlyPayments = "has_monthly_payments"
        case periodSuperUnit = "period_super_unit"
        case unitsInSuperUnit = "units_in_super_unit"
        case rowOrder = "row_order"
        case deletedAt = "deleted_at"
        case isDefault = "is_default"
    }
}
