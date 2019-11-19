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
    let isGoalAmountRequired: Bool
    let isIncomePlannedDefault: Bool
    let buyingAssetsDefault: Bool
    let onlyBuyingAssets: Bool
    let costTitle: String
    let monthlyPaymentTitle: String
    let buyingAssetsTitle: String
    let rowOrder: Int
    let deletedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case localizedKey = "localized_key"
        case localizedName = "localized_name"
        case defaultPlannedIncomeType = "default_planned_income_type"
        case isGoalAmountRequired = "is_goal_amount_required"
        case isIncomePlannedDefault = "is_income_planned_default"
        case rowOrder = "row_order"
        case deletedAt = "deleted_at"
        case onlyBuyingAssets = "only_buying_assets"
        case costTitle = "cost_title"
        case monthlyPaymentTitle = "monthly_payment_title"
        case buyingAssetsDefault = "buying_assets_default"
        case buyingAssetsTitle = "buying_assets_title"
    }
}
