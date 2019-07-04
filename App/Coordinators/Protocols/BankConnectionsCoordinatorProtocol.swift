//
//  SaltEdgeCoordinatorProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/06/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit
import SaltEdge

protocol BankConnectionsCoordinatorProtocol {
    func setup()
    func loadSaltEdgeProviders(topCountry: String?) -> Promise<[SEProvider]>
    func loadProviderConnection(for providerId: String) -> Promise<ProviderConnection>
    func createSaltEdgeConnectSession(providerCode: String, languageCode: String) -> Promise<URL>
    func createProviderConnection(connectionId: String, connectionSecret: String, provider: SEProvider) -> Promise<ProviderConnection>
    func loadAvailableSaltEdgeAccounts(for providerConnection: ProviderConnection, currencyCode: String?) -> Promise<[SEAccount]>
    
//    func getSaltEdgeConnection(secret: String) -> Promise<SEConnection>
//    func removeSaltEdgeConnection(secret: String) -> Promise<Void>
//    func refreshSaltEdgeConnection(secret: String,
//                           provider: SEProvider,
//                           fetchingDelegate: SEConnectionFetchingDelegate) -> Promise<Void>
//    func getSaltEdgeProvider(code: String) -> Promise<SEProvider>
    
}
