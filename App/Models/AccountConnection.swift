//
//  AccountConnection.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 03/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

struct AccountConnection : Decodable {
    let id: Int
    let account: Account
    let sourceId: Int
    let sourceType: TransactionableType
    let createdAt: Date? = nil
    
    enum CodingKeys: String, CodingKey {
        case id
        case account
        case sourceId = "source_id"
        case sourceType  = "source_type"
        case createdAt  = "created_at"
    }
}

struct AccountConnectionNestedAttributes : Encodable {
    var id: Int?
    let accountId: Int
    var shouldDestroy: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case accountId = "account_id"
        case shouldDestroy = "destroy"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let id = id {
            try container.encode(id, forKey: .id)
        }
        try container.encode(accountId, forKey: .accountId)
        if let shouldDestroy = shouldDestroy {
            try container.encode(shouldDestroy, forKey: .shouldDestroy)
        }        
    }
}
