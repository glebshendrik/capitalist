//
//  SaltEdgeCoordinator.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/06/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit
import SaltEdge
import SwifterSwift

enum BankConnectionError : Error {
    case connectionNotFound
    case canNotCreateConnection
    case allBankAccountsAlreadyUsed
}

class BankConnectionsCoordinator : BankConnectionsCoordinatorProtocol {
    private let saltEdgeManager: SaltEdgeManagerProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    private let accountsService: AccountsServiceProtocol
    private let connectionsService: ConnectionsServiceProtocol
    
    var languageCode: String {
        return String(Locale.preferredLanguages[0].prefix(2)).lowercased()
    }
    
    init(saltEdgeManager: SaltEdgeManagerProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         accountsService: AccountsServiceProtocol,
         connectionsService: ConnectionsServiceProtocol) {
        self.saltEdgeManager = saltEdgeManager
        self.accountCoordinator = accountCoordinator
        self.accountsService = accountsService
        self.connectionsService = connectionsService
    }
    
    func setup() {
        saltEdgeManager.set(appId: "eKNImuTofAJB4l6dGvcTr95ghTTh3zDa0HwNkVv8AL8",
                            appSecret: "z3_Hs33KX1DDa-kj2bwLlSIjWzFzif3ScebPRqzHzOA")
    }
    
    func loadProviders(country: String?) -> Promise<[SEProvider]> {
        return saltEdgeManager.loadProviders(country: country)
    }
    
    func createConnectSession(providerCode: String, countryCode: String) -> Promise<URL> {
        return saltEdgeManager.createConnectSession(providerCode: providerCode, countryCode: countryCode, languageCode: languageCode)
    }
    
    func createReconnectSession(connection: Connection) -> Promise<URL> {
        return saltEdgeManager.createReconnectSession(connectionSecret: connection.secret, languageCode: languageCode)
    }
    
    func createRefreshConnectionSession(connection: Connection) -> Promise<URL> {
        return saltEdgeManager.createRefreshConnectionSession(connectionSecret: connection.secret, languageCode: languageCode)
    }
    
    func loadConnection(for provider: SEProvider) -> Promise<Connection> {
        guard let currentUserId = accountCoordinator.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return  firstly {
                    connectionsService.index(for: currentUserId, providerId: provider.id)
                }.then { connections -> Promise<Connection> in
                    guard let connection = connections.first else {
                        return Promise(error: BankConnectionError.connectionNotFound)
                    }
                    guard let connectionId = connection.id else {
                        return self.saveConnection(connection: connection, provider: provider)
                    }
                    return self.updatedConnection(id: connectionId, saltedgeId: connection.saltedgeId)
                }
    }
    
    func saveConnection(connection: Connection, provider: SEProvider) -> Promise<Connection> {
        return  firstly {
                    saltEdgeManager.getConnection(secret: connection.secret)
                }.then { saltedgeConnection in
                    self.createConnection(saltedgeConnection, provider: provider)
                }
    }
    
    func createConnection(connectionSecret: String, provider: SEProvider) -> Promise<Connection> {
        return  firstly {
                    saltEdgeManager.getConnection(secret: connectionSecret)
                }.then { saltedgeConnection in
                    self.createConnection(saltedgeConnection, provider: provider)
                }
    }
    
    func createConnection(_ saltedgeConnection: SEConnection, provider: SEProvider) -> Promise<Connection> {
        guard let currentUserId = accountCoordinator.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }

        let form = ConnectionCreationForm(userId: currentUserId,
                                          saltedgeId: saltedgeConnection.id,
//                                          secret: saltedgeConnection.secret,
                                          providerId: provider.id,
                                          providerCode: provider.code,
                                          providerName: provider.name,
                                          countryCode: provider.countryCode,
                                          providerLogoURL: URL(string: provider.logoURL),
                                          status: ConnectionStatus.from(string: saltedgeConnection.status))
        return  firstly {
                    connectionsService.create(with: form)
                }.then { connection in
                    self.updatedConnection(id: connection.id!, saltedgeId: connection.saltedgeId)
                }
    }
    
    func updateConnection(id: Int, saltedgeId: String?) -> Promise<Void> {
        let form = ConnectionUpdatingForm(id: id, saltedgeId: saltedgeId)
        return connectionsService.update(with: form)
    }
    
    func updatedConnection(id: Int, saltedgeId: String?) -> Promise<Connection> {
        return  firstly {
                    updateConnection(id: id, saltedgeId: saltedgeId)
                }.then {
                    self.show(by: id)
                }
    }
    
    func show(by id: Int) -> Promise<Connection> {
        return connectionsService.show(by: id)
    }
    
    func loadAccounts(currencyCode: String?, connectionId: String, providerId: String, notUsed: Bool, nature: AccountNatureType) -> Promise<[Account]> {
        guard let currentUserId = accountCoordinator.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return accountsService.index(for: currentUserId, currencyCode: currencyCode, connectionId: connectionId, providerId: providerId, notUsed: notUsed, nature: nature)
    }
    
    func refreshSaltEdgeConnection(secret: String, fetchingDelegate: SEConnectionFetchingDelegate) -> Promise<Void> {
        return saltEdgeManager.refreshConnection(secret: secret, fetchingDelegate: fetchingDelegate)
    }
}

extension BankConnectionsCoordinator {
    private func updateCustomerSecret() -> Promise<String> {
        return  firstly {
                    accountCoordinator.loadCurrentUser()
                }.then { user -> Promise<String> in
                    if let customerSecret = user.saltEdgeCustomerSecret {
                        return self.setCustomerSecret(customerSecret: customerSecret)
                    }
                    return self.createCustomerSecret(user: user)
                }
    }
    
    private func setCustomerSecret(customerSecret: String) -> Promise<String> {
        saltEdgeManager.set(customerSecret: customerSecret)
        return Promise.value(customerSecret)
    }
    
    private func createCustomerSecret(user: User) -> Promise<String> {
        return  firstly {
                    saltEdgeManager.createCustomer(identifier: user.saltEdgeIdentifier)
                }.then { secret in
                    return self.updateUser(user: user, saltEdgeCustomerSecret: secret)
                }
    }
    
    private func updateUser(user: User, saltEdgeCustomerSecret: String) -> Promise<String> {
        let form = UserUpdatingForm(userId: user.id,
                                    firstname: user.firstname,
                                    saltEdgeCustomerSecret: saltEdgeCustomerSecret)
        return  firstly {
                    accountCoordinator.updateUser(with: form)
                }.then {
                    return self.setCustomerSecret(customerSecret: saltEdgeCustomerSecret)
                }
    }
}

extension BankConnectionsCoordinator {
    private func getSaltEdgeConnection(secret: String) -> Promise<SEConnection> {
        return saltEdgeManager.getConnection(secret: secret)
    }
    
    private func removeSaltEdgeConnection(secret: String) -> Promise<Void> {
        return saltEdgeManager.removeConnection(secret: secret)
    }
    
    private func getSaltEdgeProvider(code: String) -> Promise<SEProvider> {
        return saltEdgeManager.getProvider(code: code)
    }
}
