//
//  ProviderConnectionViewModel.swift
//  Capitalist
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
    var connection: Connection? = nil {
        didSet {
            if (connection?.lastStage?.isFetching ?? false) {
                fetchingStarted = true
            }
        }
    }
    var connectionSession: ConnectionSession!
    
    var shouldAskClose: Bool {
        return connectionSession.type == .refreshing && !fetchingStarted
    }
    
    public private(set) var fetchingStarted: Bool = false    
    
    init(bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol) {
        self.bankConnectionsCoordinator = bankConnectionsCoordinator
    }
    
    func setupConnection(id: String, secret: String) -> Promise<Connection> {
        if let connectionId = connection?.id {
            return updatedConnection(connectionId, id: id, secret: secret)
        }
        if  connectionSession.type == .creating,
            let provider = providerViewModel?.provider {
            
            return createConnection(secret: secret,
                                    provider: provider)
        }
        return Promise(error: BankConnectionError.canNotCreateConnection)
    }
    
    private func updatedConnection(_ connectionId: Int, id: String, secret: String) -> Promise<Connection> {
        let saltedgeId = (id == connection?.saltedgeId)
            ? nil
            : id
        return
            firstly {
                bankConnectionsCoordinator.updatedConnection(id: connectionId,
                                                             saltedgeId: saltedgeId,
                                                             session: connectionSession,
                                                             interactiveCredentials: [])
            }.get { connection in
                self.connection = connection
            }
    }
    
    private func createConnection(secret: String, provider: SEProvider) -> Promise<Connection> {
        return
            firstly {
                bankConnectionsCoordinator.createConnection(connectionSecret: secret,
                                                            provider: provider,
                                                            session: connectionSession)
            }.get { connection in
                self.connection = connection
            }
    }
}
