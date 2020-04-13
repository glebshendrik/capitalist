//
//  ProviderConnectionViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 08.04.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class ProviderConnectionViewModel {
    private let bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol    
    
    init(bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol) {
        self.bankConnectionsCoordinator = bankConnectionsCoordinator
    }
    
    func createProviderConnection(connectionId: String, connectionSecret: String, providerViewModel: ProviderViewModel) -> Promise<ProviderConnection> {
        return bankConnectionsCoordinator.createProviderConnection(connectionId: connectionId, connectionSecret: connectionSecret, provider: providerViewModel.provider)
    }
}
