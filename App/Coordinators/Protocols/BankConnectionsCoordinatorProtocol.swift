//
//  SaltEdgeCoordinatorProtocol.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 28/06/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit
import SaltEdge

protocol BankConnectionsCoordinatorProtocol {
    func setup()

    // Providers
    func loadProviders(country: String?) -> Promise<[SEProvider]>

    // Sessions
    func createCreatingConnectionSession(provider: SEProvider?,
                                         expenseSource: ExpenseSource,
                                         useMaxFetchInterval: Bool) -> Promise<ConnectionSession>
    func createCreatingConnectionSession(providerCode: String,
                                         countryCode: String,
                                         fromDate: Date?) -> Promise<ConnectionSession>
    func createRefreshingConnectionSession(connection: Connection,
                                           fromDate: Date?) -> Promise<ConnectionSession>
    func createReconnectingConnectionSession(connection: Connection,
                                             fromDate: Date?) -> Promise<ConnectionSession>

    // Connections
    func loadConnection(for provider: SEProvider) -> Promise<Connection>
    func createConnection(_ saltedgeConnection: SEConnection, provider: SEProvider, session: ConnectionSession?) -> Promise<Connection>
    func createConnection(connectionSecret: String, provider: SEProvider, session: ConnectionSession?) -> Promise<Connection>
    func saveConnection(connection: Connection, provider: SEProvider, session: ConnectionSession?) -> Promise<Connection>
    func show(by id: Int) -> Promise<Connection>
    func updatedConnection(id: Int, saltedgeId: String?, session: ConnectionSession?) -> Promise<Connection>
    func updateConnection(id: Int, saltedgeId: String?, session: ConnectionSession?) -> Promise<Void>

    // Accounts
    func loadAccounts(currencyCode: String?,
                      connectionId: String,
                      providerId: String,
                      notUsed: Bool,
                      nature: AccountNatureType) -> Promise<[Account]>
    
//    func getSaltEdgeConnection(secret: String) -> Promise<SEConnection>
//    func removeSaltEdgeConnection(secret: String) -> Promise<Void>
//    func getSaltEdgeProvider(code: String) -> Promise<SEProvider>
}
