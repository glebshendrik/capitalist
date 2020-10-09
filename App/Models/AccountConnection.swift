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
    let account: Account?
    let connection: Connection
    let sourceId: Int
    let sourceType: TransactionableType
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case account
        case connection
        case sourceId = "source_id"
        case sourceType  = "source_type"
        case createdAt  = "created_at"
    }
}

struct AccountConnectionNestedAttributes : Encodable {
    var id: Int?
    let connectionId: Int?
    let accountId: Int?
    var shouldDestroy: Bool?
    
//    let sessionURL: String?
//    let sessionExpiresAt: Date?
//    let providerId: String?
//    let providerCode: String?
//    let providerName: String?
//    let countryCode: String?
//    let providerLogoURL: URL?
//    let saltedgeConnectionId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case connectionId = "connection_id"
        case accountId = "account_id"
        case shouldDestroy = "destroy"
//        case sessionURL = "connection_session_url"
//        case sessionExpiresAt = "connection_session_expires_at"
//        case providerId = "provider_id"
//        case providerCode = "provider_code"
//        case providerName = "provider_name"
//        case countryCode = "country_code"
//        case providerLogoURL = "logo_url"
//        case saltedgeConnectionId = "salt_edge_connection_id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
                
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(connectionId, forKey: .connectionId)
        try container.encode(accountId, forKey: .accountId)
        try container.encodeIfPresent(shouldDestroy, forKey: .shouldDestroy)
    }
}
