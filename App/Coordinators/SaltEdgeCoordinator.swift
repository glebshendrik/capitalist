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

class SaltEdgeCoordinator : SaltEdgeCoordinatorProtocol {
    private let saltEdgeManager: SaltEdgeManagerProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    
    init(saltEdgeManager: SaltEdgeManagerProtocol,
         accountCoordinator: AccountCoordinatorProtocol) {
        self.saltEdgeManager = saltEdgeManager
        self.accountCoordinator = accountCoordinator
    }
    
    func setup() {
        saltEdgeManager.set(appId: "4O0ZDB8aX9HNYtk9y7JcOKJ2bSu_HkqECfm2qE4VQgM",
                            appSecret: "RHMNBKrmwYPJ9o_T0R40aEBKJ6W-9OKtQSrfw0K3z6o")
    }
    
    func loadProviders(topCountry: String?) -> Promise<[SEProvider]> {
        return  firstly {
                    updateCustomerSecret()
                }.then { secret in
                    self.saltEdgeManager.loadProviders(topCountry: topCountry)
                }
    }
    
    func createConnectSession(providerCode: String, languageCode: String) -> Promise<URL> {
        return saltEdgeManager.createConnectSession(providerCode: providerCode, languageCode: languageCode)
    }
    
    func getConnection(secret: String) -> Promise<SEConnection> {
        return saltEdgeManager.getConnection(secret: secret)
    }
    
    func removeConnection(secret: String) -> Promise<Void> {
        return saltEdgeManager.removeConnection(secret: secret)
    }
    
    func refreshConnection(secret: String, provider: SEProvider, fetchingDelegate: SEConnectionFetchingDelegate) -> Promise<Void> {
        return saltEdgeManager.refreshConnection(secret: secret, provider: provider, fetchingDelegate: fetchingDelegate)
    }
    
    func getProvider(code: String) -> Promise<SEProvider> {
        return saltEdgeManager.getProvider(code: code)
    }
    
    func loadAccounts(for connectionSecret: String) -> Promise<[SEAccount]> {
        return saltEdgeManager.loadAccounts(for: connectionSecret)
    }
}

extension SaltEdgeCoordinator {
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
