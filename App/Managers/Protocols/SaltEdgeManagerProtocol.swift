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
    func loadProviders(country: String?) -> Promise<[SEProvider]>
    func createCreatingConnectionSession(providerCode: String,
                                         countryCode: String,
                                         fromDate: Date,
                                         languageCode: String) -> Promise<ConnectionSession>
    func createRefreshingConnectionSession(connectionSecret: String,
                                           fromDate: Date,
                                           languageCode: String) -> Promise<ConnectionSession>
    func createReconnectingConnectionSession(connectionSecret: String,
                                             fromDate: Date,
                                             languageCode: String) -> Promise<ConnectionSession>
    func getConnection(secret: String) -> Promise<SEConnection>
    func removeConnection(secret: String) -> Promise<Void>
    func getProvider(code: String) -> Promise<SEProvider>
//    func loadAccounts(for connectionSecret: String) -> Promise<[SEAccount]>
}
