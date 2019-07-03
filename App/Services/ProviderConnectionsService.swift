//
//  ProviderConnectionsService.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 03/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class ProviderConnectionsService : Service, ProviderConnectionsServiceProtocol {
    func index(for userId: Int, providerId: String) -> Promise<[ProviderConnection]> {
        return requestCollection(APIResource.indexProviderConnections(userId: userId, providerId: providerId))
    }
    
    func create(with creationForm: ProviderConnectionCreationForm) -> Promise<ProviderConnection> {
        return request(APIResource.createProviderConnection(form: creationForm))
    }
}
