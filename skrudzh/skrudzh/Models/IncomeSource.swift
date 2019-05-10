//
//  IncomeSource.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 12/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation

struct IncomeSource : Decodable {
    let id: Int
    let name: String
    let currency: Currency
    let gotCentsAtPeriod: Int
    let iconURL: URL?
    let order: Int
    let deletedAt: Date?
    let isChild: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case currency
        case gotCentsAtPeriod = "got_cents_at_period"
        case iconURL = "icon_url"
        case order = "row_order"
        case deletedAt = "deleted_at"
        case isChild = "is_child"
    }

}

struct IncomeSourceCreationForm : Encodable {
    let userId: Int
    let name: String
    let currency: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case currency
    }
}

struct IncomeSourceUpdatingForm : Encodable {
    let id: Int
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case name
    }
}

struct IncomeSourcePositionUpdatingForm : Encodable {
    let id: Int
    let position: Int
    
    enum CodingKeys: String, CodingKey {
        case position = "row_order_position"
    }
}
