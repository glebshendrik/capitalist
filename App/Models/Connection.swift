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
    case deleted
    
    static func from(string: String) -> ConnectionStatus {
        switch string {
        case "active":
            return .active
        case "inactive":
            return .inactive
        default:
            return .deleted
        }
    }
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
    let interactive: Bool?
    let nextRefreshPossibleAt: Date?
    let createdAt: Date?
    let updatedAt: Date?
        
    enum CodingKeys: String, CodingKey {
        case id
        case saltedgeId = "saltedge_connection_id"
        case secret = "secret"
        case providerId = "provider_id"
        case providerCode = "provider_code"
        case providerName = "provider_name"
        case providerLogoURL = "provider_logo_url"
        case countryCode = "country_code"
        case status
        case interactive
        case nextRefreshPossibleAt = "next_refresh_possible_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ConnectionCreationForm : Encodable {
    let userId: Int
    let saltedgeId: String
//    let secret: String
    let providerId: String
    let providerCode: String
    let providerName: String
    let countryCode: String
    let providerLogoURL: URL?
    let status: ConnectionStatus
    
    enum CodingKeys: String, CodingKey {
        case saltedgeId = "salt_edge_connection_id"
//        case secret = "secret"
        case providerId = "provider_id"
        case providerCode = "provider_code"
        case providerName = "provider_name"
        case providerLogoURL = "logo_url"
        case status
    }
}

struct ConnectionUpdatingForm : Encodable {
    let id: Int?
    let saltedgeId: String?
    
    enum CodingKeys: String, CodingKey {
        case saltedgeId = "salt_edge_connection_id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let saltedgeId = saltedgeId {
            try container.encode(saltedgeId, forKey: .saltedgeId)
        }
    }
}
