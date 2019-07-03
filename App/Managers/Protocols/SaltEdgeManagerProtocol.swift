//
//  SaltEdgeManagerProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 20/06/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit
import SaltEdge

enum SaltEdgeError : Error {
    case connectionNotRemoved
    case cannotLoadProviders
    case cannotCreateConnectSession
}

protocol SaltEdgeManagerProtocol {
    func set(appId: String, appSecret: String)
    func set(customerSecret: String)
    func createCustomer(identifier: String) -> Promise<String>
    func loadProviders(topCountry: String?) -> Promise<[SEProvider]>
    func createConnectSession(providerCode: String, languageCode: String) -> Promise<URL>
    func getConnection(secret: String) -> Promise<SEConnection>
    func removeConnection(secret: String) -> Promise<Void>
    func refreshConnection(secret: String,
                           provider: SEProvider,
                           fetchingDelegate: SEConnectionFetchingDelegate) -> Promise<Void>
    func getProvider(code: String) -> Promise<SEProvider>
    func loadAccounts(for connectionSecret: String) -> Promise<[SEAccount]>
}
