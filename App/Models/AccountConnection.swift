//
//  AccountConnection.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 03/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

enum AccountNature : String, Codable {
    case account
    case bonus
    case card
    case checking
    case credit
    case creditCard = "credit_card"
    case debitCard = "debit_card"
    case ewallet
    case insurance
    case investment
    case loan
    case mortgage
    case savings
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
    var id: Int?
    let providerConnectionId: Int
    let accountId: String
    let accountName: String
    let nature: AccountNature
    let currencyCode: String
    let balance: Int
    let connectionId: String
    var shouldDestroy: Bool?
    
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let id = id {
            try container.encode(id, forKey: .id)
        }
        
        try container.encode(providerConnectionId, forKey: .providerConnectionId)
        try container.encode(accountId, forKey: .accountId)
        try container.encode(accountName, forKey: .accountName)
        try container.encode(nature, forKey: .nature)
        try container.encode(currencyCode, forKey: .currencyCode)
        try container.encode(balance, forKey: .balance)
        try container.encode(connectionId, forKey: .connectionId)
        
        if let shouldDestroy = shouldDestroy {
            try container.encode(shouldDestroy, forKey: .shouldDestroy)
        }        
    }
}
