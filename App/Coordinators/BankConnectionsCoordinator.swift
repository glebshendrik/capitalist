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
    case providerConnectionNotFound
    case allBankAccountsAlreadyUsed
}

class BankConnectionsCoordinator : BankConnectionsCoordinatorProtocol {
    private let saltEdgeManager: SaltEdgeManagerProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    private let accountConnectionsService: AccountConnectionsServiceProtocol
    private let providerConnectionsService: ProviderConnectionsServiceProtocol
    
    init(saltEdgeManager: SaltEdgeManagerProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         accountConnectionsService: AccountConnectionsServiceProtocol,
         providerConnectionsService: ProviderConnectionsServiceProtocol) {
        self.saltEdgeManager = saltEdgeManager
        self.accountCoordinator = accountCoordinator
        self.accountConnectionsService = accountConnectionsService
        self.providerConnectionsService = providerConnectionsService
    }
    
    func setup() {
        saltEdgeManager.set(appId: "4O0ZDB8aX9HNYtk9y7JcOKJ2bSu_HkqECfm2qE4VQgM",
                            appSecret: "RHMNBKrmwYPJ9o_T0R40aEBKJ6W-9OKtQSrfw0K3z6o")
    }
    
    func loadSaltEdgeProviders(topCountry: String?) -> Promise<[SEProvider]> {
        return  firstly {
                    updateCustomerSecret()
                }.then { secret in
                    self.saltEdgeManager.loadProviders(topCountry: topCountry)
                }
    }
    
    func loadProviderConnection(for providerId: String) -> Promise<ProviderConnection> {
        guard let currentUserId = accountCoordinator.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return  firstly {
                    providerConnectionsService.index(for: currentUserId, providerId: providerId)
                }.then { providerConnections -> Promise<ProviderConnection> in
                    guard let providerConnection = providerConnections.first else {
                        return Promise(error: BankConnectionError.providerConnectionNotFound)
                    }
                    return Promise.value(providerConnection)
                }
    }
    
    func createSaltEdgeConnectSession(providerCode: String, languageCode: String) -> Promise<URL> {
        return saltEdgeManager.createConnectSession(providerCode: providerCode, languageCode: languageCode)
    }
    
    func createProviderConnection(connectionId: String, connectionSecret: String, provider: SEProvider) -> Promise<ProviderConnection> {
        guard let currentUserId = accountCoordinator.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        
        let form = ProviderConnectionCreationForm(userId: currentUserId,
                                                  connectionId: connectionId,
                                                  connectionSecret: connectionSecret,
                                                  providerId: provider.id,
                                                  providerCode: provider.code,
                                                  providerName: provider.name,
                                                  logoURL: provider.logoURL,
                                                  status: .active)
        return providerConnectionsService.create(with: form)
    }
    
    func loadAvailableSaltEdgeAccounts(for providerConnection: ProviderConnection, currencyCode: String?) -> Promise<[SEAccount]> {
        return  firstly {
                    when(fulfilled: loadSaltEdgeAccounts(for: providerConnection.connectionSecret),
                                    loadUsedAccountConnections(for: providerConnection.connectionId))
                }.then { accounts, accountConnections -> Promise<[SEAccount]> in
                    
                    let usedAccountsHash = accountConnections.reduce(into: [String : AccountConnection]()) { (hash, item) in
                        hash[item.accountId] = item
                    }
                    
                    let availableAccounts = accounts.filter { account in
                        if let currencyCode = currencyCode, account.currencyCode != currencyCode {
                            return false
                        }
                        return usedAccountsHash[account.id] == nil
                    }
                    
                    return Promise.value(availableAccounts)
                }
    }
    
}

extension BankConnectionsCoordinator {
    private func loadSaltEdgeAccounts(for connectionSecret: String) -> Promise<[SEAccount]> {
        return saltEdgeManager.loadAccounts(for: connectionSecret)
    }
    
    private func loadUsedAccountConnections(for connectionId: String) -> Promise<[AccountConnection]> {
        guard let currentUserId = accountCoordinator.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return accountConnectionsService.index(for: currentUserId, connectionId: connectionId)
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
    
    private func refreshSaltEdgeConnection(secret: String, provider: SEProvider, fetchingDelegate: SEConnectionFetchingDelegate) -> Promise<Void> {
        return saltEdgeManager.refreshConnection(secret: secret, provider: provider, fetchingDelegate: fetchingDelegate)
    }
    
    private func getSaltEdgeProvider(code: String) -> Promise<SEProvider> {
        return saltEdgeManager.getProvider(code: code)
    }
}
