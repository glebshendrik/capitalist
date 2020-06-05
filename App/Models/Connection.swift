//
//  Connection.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 05.06.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation

enum ConnectionStatus : String, Codable {
    case active
    case inactive
    case disabled
}

struct Connection : Decodable {
    let id: Int?
    let saltedgeId: String
    let secret: String
    let providerId: String?
    let providerCode: String
    let providerName: String
    let countryCode: String
    let providerLogoURL: URL?
    let status: ConnectionStatus
    let createdAt: Date?
    let updatedAt: Date?
        
    enum CodingKeys: String, CodingKey {
        case id
        case saltedgeId = "saltedge_connection_id"
        case secret = "secret"
        case providerId = "provider_id"
        case providerCode = "provider_code"
        case providerName = "provider_name"
        case providerLogoURL = "logo_url"
        case countryCode = "country_code"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ConnectionCreationForm : Encodable {
    let userId: Int
    let saltedgeId: String
    let secret: String
    let providerId: String
    let providerCode: String
    let providerName: String
    let countryCode: String
    let providerLogoURL: URL?
    let status: ConnectionStatus
    
    enum CodingKeys: String, CodingKey {
        case saltedgeId = "saltedge_connection_id"
        case secret = "secret"
        case providerId = "provider_id"
        case providerCode = "provider_code"
        case providerName = "provider_name"
        case providerLogoURL = "logo_url"
        case status
    }
}
