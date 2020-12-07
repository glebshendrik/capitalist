//
//  SaltEdgeCustomer.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 07.12.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation

struct SaltEdgeCustomer : Codable {
    let id: String
    let secret: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case secret
    }
}
