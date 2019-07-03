//
//  AccountConnection.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 03/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

enum AccountNature : String, Codable {
    case active
    case inactive
    case disabled
}

struct AccountConnection : Decodable {
    let id: Int
    let accountId: String
    let accountName: String
    let nature: AccountNature
    let currencyCode: String
    let balance: Int
    let connectionId: String
    let providerConnection: ProviderConnection
    
    enum CodingKeys: String, CodingKey {
        case id
        case accountId = "account_id"
        case accountName = "account_name"
        case nature
        case currencyCode = "currency_code"
        case balance
        case connectionId = "salt_edge_connection_id"
        case providerConnection = "provider_connection"
    }
}

struct AccountConnectionNestedAttributes : Encodable {
    let id: Int
    let providerConnectionId: Int
    let accountId: String
    let accountName: String
    let nature: AccountNature
    let currencyCode: String
    let balance: Int
    let connectionId: String
    let shouldDestroy: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case providerConnectionId = "provider_connection_id"
        case accountId = "account_id"
        case accountName = "account_name"
        case nature
        case currencyCode = "currency_code"
        case balance
        case connectionId = "salt_edge_connection_id"
        case shouldDestroy = "_destroy"
    }
}
