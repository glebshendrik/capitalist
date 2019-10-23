//
//  Basket.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 14/01/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

enum BasketType : String, Codable {
    case joy = "joy"
    case risk = "risk"
    case safe = "safe"
    
    var iconCategory: IconCategory {
        switch self {
        case .joy:
            return .expenseCategoryJoy
        case .risk:
            return .expenseCategoryRisk
        case .safe:
            return .expenseCategorySafe
        }
    }
    
    var defaultIconBackground: String {
        switch self {
        case .joy:
            return "joy-background"
        case .risk:
            return "risk-background"
        case .safe:
            return "safe-background"
        }
    }
    
    var defaultIconEditBackground: String {
        switch self {
        case .joy:
            return "joy-category-background-pic"
        case .risk:
            return "risk-category-background-pic"
        case .safe:
            return "safe-category-background-pic"
        }
    }
    
    var defaultProgressBackground: String {
        switch self {
        case .joy:
            return "joy-planned-background"
        case .risk:
            return "risk-planned-background"
        case .safe:
            return "safe-planned-background"
        }
    }
}

struct Basket : Decodable {
    let id: Int
    let basketType: BasketType
    var spentCentsAtPeriod: Int
    let spentCurrency: String
    let currency: Currency
    
    enum CodingKeys: String, CodingKey {
        case id
        case basketType = "basket_type"
        case spentCentsAtPeriod = "spent_cents_at_period"
        case spentCurrency = "spent_currency"
        case currency
    }
}
