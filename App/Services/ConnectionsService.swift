//
//  ProviderConnectionsService.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 03/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class ConnectionsService : Service, ConnectionsServiceProtocol {
    func index(for userId: Int, providerId: String) -> Promise<[Connection]> {        
        return requestCollection(APIRoute.indexConnections(userId: userId, providerId: providerId))
    }
    
    func create(with creationForm: ConnectionCreationForm) -> Promise<Connection> {
        return request(APIRoute.createConnection(form: creationForm))
    }
}
