//
//  Session.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation

struct Session : Codable {
    let token: String
    let userId: Int
    
    enum CodingKeys: String, CodingKey {
        case token = "token"
        case userId = "user.id"
    }
}
