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

protocol SaltEdgeCoordinatorProtocol {
    func setup()
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
