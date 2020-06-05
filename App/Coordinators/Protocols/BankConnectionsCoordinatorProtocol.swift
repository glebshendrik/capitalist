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
    func loadProviders(country: String?) -> Promise<[SEProvider]>
    func loadConnection(for providerId: String) -> Promise<Connection>
    func createSaltEdgeConnectSession(provider: SEProvider, languageCode: String) -> Promise<URL>
    func createConnection(connectionId: String, connectionSecret: String, provider: SEProvider) -> Promise<Connection>
    func saveConnection(connection: Connection, provider: SEProvider) -> Promise<Connection>
    func loadAccounts(currencyCode: String?, connectionId: String, providerId: String, notUsed: Bool) -> Promise<[Account]>
    
    
//    func getSaltEdgeConnection(secret: String) -> Promise<SEConnection>
//    func removeSaltEdgeConnection(secret: String) -> Promise<Void>
//    func refreshSaltEdgeConnection(secret: String,
//                           provider: SEProvider,
//                           fetchingDelegate: SEConnectionFetchingDelegate) -> Promise<Void>
//    func getSaltEdgeProvider(code: String) -> Promise<SEProvider>
    
}
