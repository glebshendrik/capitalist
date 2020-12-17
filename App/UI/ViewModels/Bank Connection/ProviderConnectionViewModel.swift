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
    var shouldAskClose: Bool {
        return connectionType == .refresh
    }
    
    init(bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol) {
        self.bankConnectionsCoordinator = bankConnectionsCoordinator
    }
    
    func setupConnection(id: String, secret: String) -> Promise<Connection> {
        if let connectionId = connection?.id {
            let saltedgeId = id == connection?.saltedgeId ? nil : id

            return bankConnectionsCoordinator.updatedConnection(id: connectionId, saltedgeId: saltedgeId)
        }
        if  connectionType == .create,
            let provider = providerViewModel?.provider {
            
            return bankConnectionsCoordinator.createConnection(connectionSecret: secret, provider: provider)
        }
        return Promise(error: BankConnectionError.canNotCreateConnection)
    }
}
