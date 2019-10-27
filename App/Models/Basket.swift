//
//  Basket.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 14/01/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

enum ItemSize : String {
    case tiny = "xs"
    case small = "s"
    case medium = "m"
    case large = "l"
}

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
        
    var progressBackgroundName: String {
        return "\(self.rawValue)-progress-background"
    }
    
    func iconBackgroundName(size: ItemSize) -> String {
        return "\(self.rawValue)-icon-bkg-\(size.rawValue)"
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
