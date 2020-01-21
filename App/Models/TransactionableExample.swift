//
//  TransactionableExample.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21.01.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation

struct TransactionableExample : Decodable {
    let id: Int
    let name: String
    let localizedKey: String
    let localizedName: String
    let iconURL: URL?
    let transactionableType: TransactionableType
    let basketType: BasketType?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case localizedKey = "localized_key"
        case localizedName = "localized_name"
        case iconURL = "icon_url"
        case transactionableType = "transactionable_type"
        case basketType = "basket_type"
    }
}
