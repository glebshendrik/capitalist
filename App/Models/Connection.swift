//
//  Connection.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 05.06.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation
import SaltEdge

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
    
    var isFetching: Bool {
        switch self {
            case .fetchAccounts, .fetchFull, .fetchRecent, .fetchHolderInfo:
                return true
            default:
                return false
        }
    }
    
    var isInteractive: Bool {
        return self == .interactive
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
    let lastSuccessAt: Date?
    let session: ConnectionSession?
    let createdAt: Date?
    let updatedAt: Date?
    var provider: SEProvider? = nil
    let requiredInteractiveFieldsNames: [String]
        
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
        case requiredInteractiveFieldsNames = "required_interactive_fields_names"
        case lastSuccessAt = "last_success_at"
    }
    
    var isConnectedSuccessfully: Bool {
        return lastSuccessAt != nil
    }
    
    var reconnectNeeded: Bool {
        guard
            let stage = lastStage,
            (stage == .finish || stage.isInteractive)
        else {
            return false
        }
        
        guard
            status == .active
        else {
            return true
        }
                
        guard
            let interactive = interactive
        else {
            return false
        }
        
        guard
            let nextRefreshPossibleAt = nextRefreshPossibleAt
        else {
            return stage.isInteractive || !isConnectedSuccessfully
        }
        return interactive && nextRefreshPossibleAt.isInPast || !isConnectedSuccessfully
    }
    
    var isSyncing: Bool {
        guard
            let stage = lastStage
        else {
            return false
        }
        return stage != .finish
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
    let interactiveCredentials: [InteractiveCredentialsField]
    
    enum CodingKeys: String, CodingKey {
        case saltedgeId = "salt_edge_connection_id"
        case session = "saltedge_connection_session"
        case interactiveCredentials = "interactive_credentials"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(saltedgeId, forKey: .saltedgeId)
        try container.encodeIfPresent(session, forKey: .session)
        if !interactiveCredentials.isEmpty {
            try container.encodeIfPresent(interactiveCredentials, forKey: .interactiveCredentials)
        }
    }
}

struct InteractiveCredentialsField : Encodable {
    let name: String
    var value: String?
    let displayName: String
    let nature: InteractiveCredentialsFieldNature?
    let options: [SEProviderFieldOption]?
    let position: Int
    let optional: Bool
    
    enum CodingKeys: String, CodingKey {
        case name
        case value
    }
}

enum InteractiveCredentialsFieldNature : String, Codable {
    case text
    case password
    case select
    case dynamicSelect = "dynamic_select"
    case file
    case number
    
    var isPresentable: Bool {
        return self != .dynamicSelect && self != .file
    }
    
    static func nature(rawValue: String?) -> InteractiveCredentialsFieldNature? {
        guard
            let rawValue = rawValue
        else {
            return nil
        }
        return self.init(rawValue: rawValue)
    }
}
