//
//  ProviderConnectionViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 08.04.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit
import SaltEdge

enum ProviderConnectionType {
    case create
    case refresh
    case reconnect
}

class ProviderConnectionViewModel {
    private let bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol    
    
    var providerViewModel: ProviderViewModel? = nil
    var connectionType: ProviderConnectionType = .create
    var connectionURL: URL? = nil    
    var connection: Connection? = nil    
    
    init(bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol) {
        self.bankConnectionsCoordinator = bankConnectionsCoordinator
    }
    
    func createConnection(_ connection: SEConnection, providerViewModel: ProviderViewModel) -> Promise<Connection> {
        return bankConnectionsCoordinator.createConnection(connection, provider: providerViewModel.provider)
    }
    
    func setupConnection(id: String, secret: String) -> Promise<Connection> {
        guard let provider = providerViewModel?.provider else { return Promise(error: BankConnectionError.canNotCreateConnection) }
        
        guard let connectionId = connection?.id else {
            if connectionType == .create {
                return bankConnectionsCoordinator.createConnection(connectionSecret: secret, provider: provider)
            }
            return Promise(error: BankConnectionError.canNotCreateConnection)
        }
        
        let saltedgeId = id == connection?.saltedgeId ? nil : id
        return bankConnectionsCoordinator.updateConnection(id: connectionId, saltedgeId: saltedgeId)
    }
}
