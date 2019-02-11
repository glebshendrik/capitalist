//
//  Currency.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 06/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation

struct Currency : Decodable {
    let code: String
    let name: String
    let translatedName: String
    let symbol: String
    let subunitToUnit: Int
    let decimalMark: String
    let symbolFirst: Bool
    let priority: Int
    let thousandsSeparator: String
    
    enum CodingKeys: String, CodingKey {
        case code = "iso_code"
        case name = "name"
        case translatedName = "translated_name"
        case symbol = "symbol"
        case subunitToUnit = "subunit_to_unit"
        case decimalMark = "decimal_mark"
        case symbolFirst = "symbol_first"
        case priority = "priority"
        case thousandsSeparator = "thousands_separator"
    }
}
