//
//  Basket.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 14/01/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation

enum BasketType : String, Codable {
    case joy = "joy"
    case risk = "risk"
    case safe = "safe"
}

struct Basket : Decodable {
    let id: Int
    let basketType: BasketType
    var monthlySpentCents: Int
    let monthlySpentCurrency: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case basketType = "basket_type"
        case monthlySpentCents = "monthly_spent_cents"
        case monthlySpentCurrency = "monthly_spent_currency"
    }
}
