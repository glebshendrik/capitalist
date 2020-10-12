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

enum ConnectionStage : String, Codable {
    case start
    case connect
    case interactive
    case fetchHolderInfo = "fetch_holder_info"
    case fetchAccounts = "fetch_accounts"
    case fetchRecent = "fetch_recent"
    case fetchFull = "fetch_full"
    case disconnect
    case finish
    
    var message: String {
        switch self {
            case .start:
                return NSLocalizedString("Начало подключения к банку", comment: "")
            case .connect:
                return NSLocalizedString("Подключение к банку", comment: "")
            case .interactive:
                return NSLocalizedString("Аутентификация", comment: "")
            case .fetchHolderInfo:
                return NSLocalizedString("Загрузка данных держателя счетов", comment: "")
            case .fetchAccounts:
                return NSLocalizedString("Загрузка данных счетов", comment: "")
            case .fetchFull:
                return NSLocalizedString("Загрузка данных транзакций", comment: "")
            case .fetchRecent:
                return NSLocalizedString("Загрузка данных транзакций", comment: "")
            case .disconnect:
                return NSLocalizedString("Отключение от банка", comment: "")
            case .finish:
                return NSLocalizedString("Подключение к банку завершено", comment: "")
        }
    }
}

enum ConnectionSessionType : String, Codable {
    case creating
    case refreshing
    case reconnecting
}

struct ConnectionSession : Codable {
    let url: URL
    let type: ConnectionSessionType
    let expiresAt: Date
    
    enum CodingKeys: String, CodingKey {
        case url
        case type
        case expiresAt = "expires_at"
    }
}

struct Connection : Decodable {
    let id: Int?
    let saltedgeId: String?
    let secret: String
    let providerId: String?
    let providerCode: String
    let providerName: String
    let countryCode: String
    let providerLogoURL: URL?
    let status: ConnectionStatus
    let interactive: Bool?
    let nextRefreshPossibleAt: Date?
    let lastStage: ConnectionStage?
    let session: ConnectionSession?
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
        case lastStage = "last_stage"
        case session = "saltedge_connection_session"
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
    let session: ConnectionSession?
    let status: ConnectionStatus
    
    enum CodingKeys: String, CodingKey {
        case saltedgeId = "salt_edge_connection_id"
//        case secret = "secret"
        case providerId = "provider_id"
        case providerCode = "provider_code"
        case providerName = "provider_name"
        case providerLogoURL = "logo_url"
        case session = "saltedge_connection_session"
        case status
    }
}

struct ConnectionUpdatingForm : Encodable {
    let id: Int?
    let saltedgeId: String?
    let session: ConnectionSession?
    
    enum CodingKeys: String, CodingKey {
        case saltedgeId = "salt_edge_connection_id"
        case session = "saltedge_connection_session"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(saltedgeId, forKey: .saltedgeId)
        try container.encodeIfPresent(session, forKey: .session)
    }
}
