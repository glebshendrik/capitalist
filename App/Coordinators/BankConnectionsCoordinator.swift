//
//  SaltEdgeCoordinator.swift
//  Capitalist
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
    case noProviderToLoadConnection
}

class BankConnectionsCoordinator : BankConnectionsCoordinatorProtocol {   
    
    private let saltEdgeManager: SaltEdgeManagerProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    private let accountsService: AccountsServiceProtocol
    private let connectionsService: ConnectionsServiceProtocol
    private let expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol
    
    var languageCode: String {
        return String(Locale.preferredLanguages[0].prefix(2)).lowercased()
    }
    
    init(saltEdgeManager: SaltEdgeManagerProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         accountsService: AccountsServiceProtocol,
         connectionsService: ConnectionsServiceProtocol,
         expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol) {
        self.saltEdgeManager = saltEdgeManager
        self.accountCoordinator = accountCoordinator
        self.accountsService = accountsService
        self.connectionsService = connectionsService
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
    }
    
    func setup() {
        // Test account
        saltEdgeManager.set(appId: "7vMi6aIbqc9yjaxViEzvOlDWGWa3n1CYsbY5TH5Z32Q",
                            appSecret: "tjtZVMKT16TM7TUl-Lb5HjJb7Tf9tNr5IfVFRMRp-Tw")
        // Live account
        //        saltEdgeManager.set(appId: "eKNImuTofAJB4l6dGvcTr95ghTTh3zDa0HwNkVv8AL8",
        //                            appSecret: "z3_Hs33KX1DDa-kj2bwLlSIjWzFzif3ScebPRqzHzOA")
    }
    
    func loadProviders(country: String?) -> Promise<[SEProvider]> {
        return saltEdgeManager.loadProviders(country: country)
    }
    
    func createCreatingConnectionSession(provider: SEProvider?,
                                         expenseSource: ExpenseSource,
                                         useMaxFetchInterval: Bool) -> Promise<ConnectionSession> {
        let oldConnection = expenseSource.accountConnection?.connection
        guard
            (oldConnection != nil || provider != nil)
        else {
            return Promise(error: BankConnectionError.noProviderToLoadConnection)
        }
        
        if let connection = oldConnection,
           let session = connection.session,
           session.expiresAt.isInFuture,
           session.type == .creating {
            
            return Promise.value(session)
        }
        return
            firstly {
                connectionFetchFromDate(provider: provider,
                                        expenseSource: expenseSource,
                                        useMaxFetchInterval: useMaxFetchInterval)
            }.then { fromDate in
                self.createCreatingConnectionSession(providerCode: (provider?.code ?? oldConnection?.providerCode)!,
                                                     countryCode: (provider?.countryCode ?? oldConnection?.countryCode)!,
                                                     fromDate: fromDate)
            }
    }
    
    func createCreatingConnectionSession(providerCode: String,
                                         countryCode: String,
                                         fromDate: Date?) -> Promise<ConnectionSession> {
        return saltEdgeManager.createCreatingConnectionSession(providerCode: providerCode,
                                                               countryCode: countryCode,
                                                               fromDate: fromDate ?? Date(),
                                                               languageCode: languageCode)
    }
    
    func createRefreshingConnectionSession(connection: Connection,
                                           fromDate: Date?) -> Promise<ConnectionSession> {
        return saltEdgeManager.createRefreshingConnectionSession(connectionSecret: connection.secret,
                                                                 fromDate: fromDate ?? Date(),
                                                                 languageCode: languageCode)
    }
    
    func createReconnectingConnectionSession(connection: Connection,
                                             fromDate: Date?) -> Promise<ConnectionSession> {
        if let session = connection.session,
           session.expiresAt.isInFuture,
           session.type == .reconnecting {
            
            return Promise.value(session)
        }
        return saltEdgeManager.createReconnectingConnectionSession(connectionSecret: connection.secret,
                                                                   fromDate: fromDate ?? Date(),
                                                                   languageCode: languageCode)
    }
    
    private func connectionFetchFromDate(provider: SEProvider?,
                                         expenseSource: ExpenseSource,
                                         useMaxFetchInterval: Bool) -> Promise<Date?> {
        guard
            let provider = provider
        else {
            return Promise.value(expenseSource.fetchDataFrom)
        }
        let maxFetchInterval = useMaxFetchInterval ? provider.maxFetchInterval : 0
//        let fetchFromDate = useMaxFetchInterval ? Date().adding(.day, value: (1 - maxFetchInterval)) : Date()
        return
            firstly {
                expenseSourcesCoordinator.updateMaxFetchInterval(with: ExpenseSourceMaxFetchIntervalUpdatingForm(id: expenseSource.id,
                                                                                                                 maxFetchInterval: maxFetchInterval))
            }.then {
                self.expenseSourcesCoordinator.show(by: expenseSource.id)
            }.map { expenseSource in
                expenseSource.fetchDataFrom
            }
    }
    
    func loadConnection(for provider: SEProvider) -> Promise<Connection> {
        guard let currentUserId = accountCoordinator.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return
            firstly {
                connectionsService.index(for: currentUserId, providerId: provider.id)
            }.then { connections -> Promise<Connection> in
                guard let connection = connections.first else {
                    return Promise(error: BankConnectionError.connectionNotFound)
                }
                guard let connectionId = connection.id else {
                    return self.saveConnection(connection: connection, provider: provider, session: nil)
                }
                return self.updatedConnection(id: connectionId, saltedgeId: connection.saltedgeId, session: nil)
            }
    }
    
    func saveConnection(connection: Connection, provider: SEProvider, session: ConnectionSession?) -> Promise<Connection> {
        return
            firstly {
                saltEdgeManager.getConnection(secret: connection.secret)
            }.then { saltedgeConnection in
                self.createConnection(saltedgeConnection, provider: provider, session: session)
            }
    }
    
    func createConnection(connectionSecret: String, provider: SEProvider, session: ConnectionSession?) -> Promise<Connection> {
        return
            firstly {
                saltEdgeManager.getConnection(secret: connectionSecret)
            }.then { saltedgeConnection in
                self.createConnection(saltedgeConnection, provider: provider, session: session)
            }
    }
    
    func createConnection(_ saltedgeConnection: SEConnection, provider: SEProvider, session: ConnectionSession?) -> Promise<Connection> {
        guard
            let currentUserId = accountCoordinator.currentSession?.userId
        else {
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
                                          session: session,
                                          status: ConnectionStatus.from(string: saltedgeConnection.status))
        return
            firstly {
                connectionsService.create(with: form)
            }.then { connection in
                // Need to call server side logic of syncing with saltedge
                self.updatedConnection(id: connection.id!, saltedgeId: connection.saltedgeId, session: session)
            }
    }
    
    func updateConnection(id: Int, saltedgeId: String?, session: ConnectionSession?) -> Promise<Void> {
        let form = ConnectionUpdatingForm(id: id, saltedgeId: saltedgeId, session: session)
        return connectionsService.update(with: form)
    }
    
    func updatedConnection(id: Int, saltedgeId: String?, session: ConnectionSession?) -> Promise<Connection> {
        return
            firstly {
                updateConnection(id: id, saltedgeId: saltedgeId, session: session)
            }.then {
                self.show(by: id)
            }
    }
    
    func show(by id: Int) -> Promise<Connection> {
        return connectionsService.show(by: id)
    }
    
    func loadAccounts(currencyCode: String?,
                      connectionId: String,
                      providerId: String,
                      notUsed: Bool,
                      nature: AccountNatureType) -> Promise<[Account]> {
        guard
            let currentUserId = accountCoordinator.currentSession?.userId
        else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return accountsService.index(for: currentUserId,
                                     currencyCode: currencyCode,
                                     connectionId: connectionId,
                                     providerId: providerId,
                                     notUsed: notUsed,
                                     nature: nature)
    }    
}

extension BankConnectionsCoordinator {
    private func updateCustomerSecret() -> Promise<String> {
        return
            firstly {
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
        return
            firstly {
                saltEdgeManager.createCustomer(identifier: user.saltEdgeIdentifier)
            }.then { secret in
                return self.updateUser(user: user, saltEdgeCustomerSecret: secret)
            }
    }
    
    private func updateUser(user: User, saltEdgeCustomerSecret: String) -> Promise<String> {
        let form = UserUpdatingForm(userId: user.id,
                                    firstname: user.firstname,
                                    saltEdgeCustomerSecret: saltEdgeCustomerSecret)
        return
            firstly {
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
