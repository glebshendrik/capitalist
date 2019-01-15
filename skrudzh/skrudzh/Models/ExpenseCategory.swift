//
//  ExpenseCategory.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 14/01/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation

struct ExpenseCategory : Decodable {
    let id: Int
    let name: String
    let iconURL: URL?
    let basketId: Int
    let basketType: BasketType
    let monthlyPlannedCurrency: String
    let monthlyPlannedCents: Int
    let monthlySpentCents: Int
    let monthlySpentCurrency: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case iconURL = "icon_url"
        case basketId = "basket_id"
        case basketType = "basket_type"
        case monthlyPlannedCurrency = "monthly_planned_currency"
        case monthlyPlannedCents = "monthly_planned_cents"
        case monthlySpentCents = "monthly_spent_cents"
        case monthlySpentCurrency = "monthly_spent_currency"
    }
    
}

struct ExpenseCategoryCreationForm : Encodable {
    let name: String
    let iconURL: URL?
    let basketId: Int
    let monthlyPlannedCurrency: String = "RUB"
    let monthlyPlannedCents: Int
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case basketId = "basket_id"
        case monthlyPlannedCurrency = "monthly_planned_currency"
        case monthlyPlannedCents = "monthly_planned_cents"
    }
    
    init(name: String, iconURL: URL?, basketId: Int, monthlyPlannedCents: Int) {
        self.name = name
        self.iconURL = iconURL
        self.basketId = basketId
        self.monthlyPlannedCents = monthlyPlannedCents
    }
}

struct ExpenseCategoryUpdatingForm : Encodable {
    let id: Int
    let name: String
    let iconURL: URL?
    let monthlyPlannedCurrency: String = "RUB"
    let monthlyPlannedCents: Int
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case monthlyPlannedCurrency = "monthly_planned_currency"
        case monthlyPlannedCents = "monthly_planned_cents"
    }
}
