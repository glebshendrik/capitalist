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
    func createConnectSession(providerCode: String, countryCode: String) -> Promise<URL>
    func createReconnectSession(connection: Connection) -> Promise<URL>
    func createRefreshConnectionSession(connection: Connection) -> Promise<URL>
    func loadConnection(for provider: SEProvider) -> Promise<Connection>
    func createConnection(_ saltedgeConnection: SEConnection, provider: SEProvider) -> Promise<Connection>
    func createConnection(connectionSecret: String, provider: SEProvider) -> Promise<Connection>
    func saveConnection(connection: Connection, provider: SEProvider) -> Promise<Connection>    
    func show(by id: Int) -> Promise<Connection>
    func updatedConnection(id: Int, saltedgeId: String?) -> Promise<Connection>
    func updateConnection(id: Int, saltedgeId: String?) -> Promise<Void>
    func loadAccounts(currencyCode: String?, connectionId: String, providerId: String, notUsed: Bool, nature: AccountNatureType) -> Promise<[Account]>
    
    

    
//    func getSaltEdgeConnection(secret: String) -> Promise<SEConnection>
//    func removeSaltEdgeConnection(secret: String) -> Promise<Void>
//    func getSaltEdgeProvider(code: String) -> Promise<SEProvider>
    
}
