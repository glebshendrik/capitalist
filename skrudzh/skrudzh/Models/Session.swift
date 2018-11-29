//
//  Session.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation

struct Session : Decodable {
    let token: String
    let userId: Int
    
    enum CodingKeys: String, CodingKey {
        case token
        case user
    }
    
    init(token: String, userId: Int) {
        self.token = token
        self.userId = userId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        token = try container.decode(String.self, forKey: .token)
        let user = try container.decode(User.self, forKey: .user)
        userId = user.id
    }
}
