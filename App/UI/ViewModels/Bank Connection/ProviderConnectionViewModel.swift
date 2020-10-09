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

class ProviderConnectionViewModel {
    private let bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol    
    
    var providerViewModel: ProviderViewModel? = nil
    var connection: Connection? = nil
    var connectionSession: ConnectionSession!
    
    var shouldAskClose: Bool {
        return connectionSession.type == .refreshing && !fetchingStarted
    }
    
    var fetchingStarted: Bool = false
    
    init(bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol) {
        self.bankConnectionsCoordinator = bankConnectionsCoordinator
    }
    
    func setupConnection(id: String, secret: String) -> Promise<Connection> {
        if let connectionId = connection?.id {
            
            let saltedgeId = (id == connection?.saltedgeId)
                ? nil
                : id
            return bankConnectionsCoordinator.updatedConnection(id: connectionId,
                                                                saltedgeId: saltedgeId,
                                                                session: connectionSession)
        }
        if  connectionSession.type == .creating,
            let provider = providerViewModel?.provider {
            
            return bankConnectionsCoordinator.createConnection(connectionSecret: secret,
                                                               provider: provider,                                                               
                                                               session: connectionSession)
        }
        return Promise(error: BankConnectionError.canNotCreateConnection)
    }
}
