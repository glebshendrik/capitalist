//
//  ProviderConnectionsServiceProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 03/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol ProviderConnectionsServiceProtocol {
    func index(for userId: Int, providerId: String) -> Promise<[ProviderConnection]>
    func create(with creationForm: ProviderConnectionCreationForm) -> Promise<ProviderConnection>
}
