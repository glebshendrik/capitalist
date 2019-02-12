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
    let monthlyPlannedCurrency: String?
    let monthlyPlannedCents: Int?
    let monthlySpentCents: Int
    let monthlySpentCurrency: String
    let currency: Currency
    let order: Int
    
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
        case order = "row_order"
        case currency = "currency"
    }
    
}

struct ExpenseCategoryCreationForm : Encodable {
    let name: String
    let iconURL: URL?
    let basketId: Int
    let monthlyPlannedCurrency: String
    let monthlyPlannedCents: Int?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case basketId = "basket_id"
        case monthlyPlannedCurrency = "monthly_planned_currency"
        case monthlyPlannedCents = "monthly_planned_cents"
    }
    
    init(name: String, iconURL: URL?, basketId: Int, monthlyPlannedCents: Int?, currency: String) {
        self.name = name
        self.iconURL = iconURL
        self.basketId = basketId
        self.monthlyPlannedCents = monthlyPlannedCents
        self.monthlyPlannedCurrency = currency
    }
}

struct ExpenseCategoryUpdatingForm : Encodable {
    let id: Int
    let name: String
    let iconURL: URL?
    let monthlyPlannedCurrency: String? = "RUB"
    let monthlyPlannedCents: Int?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case monthlyPlannedCurrency = "monthly_planned_currency"
        case monthlyPlannedCents = "monthly_planned_cents"
    }
    
    init(id: Int, name: String, iconURL: URL?, monthlyPlannedCents: Int?) {
        self.id = id
        self.name = name
        self.iconURL = iconURL
        self.monthlyPlannedCents = monthlyPlannedCents
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(iconURL, forKey: .iconURL)
        try container.encode(monthlyPlannedCurrency, forKey: .monthlyPlannedCurrency)
        try container.encode(monthlyPlannedCents, forKey: .monthlyPlannedCents)
    }
}

struct ExpenseCategoryPositionUpdatingForm : Encodable {
    let id: Int
    let position: Int
    
    enum CodingKeys: String, CodingKey {
        case position = "row_order_position"
    }
}
