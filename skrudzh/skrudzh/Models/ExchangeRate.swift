//
//  ExchangeRate.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 27/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation

struct ExchangeRate : Decodable {
    let from: String
    let to: String
    let rate: Float
    
    enum CodingKeys: String, CodingKey {
        case from
        case to
        case rate
    }
}
