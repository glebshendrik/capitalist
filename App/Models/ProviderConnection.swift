//
//  ProviderConnection.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 03/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

enum ConnectionStatus : String, Codable {
    case active
    case inactive
    case disabled
}

struct ProviderConnection : Decodable {
    let id: Int
    let connectionId: String
    let connectionSecret: String
    let providerId: String
    let providerCode: String
    let providerName: String
    let logoURL: URL?
    let status: ConnectionStatus
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case connectionId = "connection_id"
        case connectionSecret = "connection_secret"
        case providerId = "provider_id"
        case providerCode = "provider_code"
        case providerName = "provider_name"
        case logoURL = "logo_url"
        case status
        case createdAt = "created_at"
    }
}

struct ProviderConnectionCreationForm : Encodable {
    let userId: Int
    let connectionId: String
    let connectionSecret: String
    let providerId: String
    let providerCode: String
    let providerName: String
    let logoURL: URL?
    let status: ConnectionStatus
    
    enum CodingKeys: String, CodingKey {
        case connectionId = "connection_id"
        case connectionSecret = "connection_secret"
        case providerId = "provider_id"
        case providerCode = "provider_code"
        case providerName = "provider_name"
        case logoURL = "logo_url"
        case status
    }
}
