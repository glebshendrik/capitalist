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
    case allBankAccountsAlreadyUsed
}

class BankConnectionsCoordinator : BankConnectionsCoordinatorProtocol {
    private let saltEdgeManager: SaltEdgeManagerProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    private let accountsService: AccountsServiceProtocol
    private let connectionsService: ConnectionsServiceProtocol
    
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
        return  firstly {
            updateCustomerSecret()
        }.then { secret in
            self.saltEdgeManager.loadProviders(country: country)
        }
//        return saltEdgeManager.loadProviders(country: country)
    }
    
    func loadConnection(for providerId: String) -> Promise<Connection> {
        guard let currentUserId = accountCoordinator.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return  firstly {
                    connectionsService.index(for: currentUserId, providerId: providerId)
                }.then { connections -> Promise<Connection> in
                    guard let connection = connections.first else {
                        return Promise(error: BankConnectionError.connectionNotFound)
                    }
                    return Promise.value(connection)
                }
    }
    
    func createSaltEdgeConnectSession(provider: SEProvider, languageCode: String) -> Promise<URL> {
        return saltEdgeManager.createConnectSession(provider: provider, languageCode: languageCode)
    }
    
    func createConnection(connectionId: String, connectionSecret: String, provider: SEProvider) -> Promise<Connection> {
        guard let currentUserId = accountCoordinator.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }

        let form = ConnectionCreationForm(userId: currentUserId,
                                          saltedgeId: connectionId,
                                          secret: connectionSecret,
                                          providerId: provider.id,
                                          providerCode: provider.code,
                                          providerName: provider.name,
                                          countryCode: provider.countryCode,
                                          providerLogoURL: URL(string: provider.logoURL),
                                          status: .active)
        return connectionsService.create(with: form)
    }
    
    func saveConnection(connection: Connection, provider: SEProvider) -> Promise<Connection> {
        return createConnection(connectionId: connection.saltedgeId, connectionSecret: connection.secret, provider: provider)
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
