//
//  ProviderConnectionsService.swift
//  Capitalist
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
    
    func show(by id: Int) -> Promise<Connection> {
        return request(APIRoute.showConnection(id: id))
    }
    
    func update(with updatingForm: ConnectionUpdatingForm) -> Promise<Void> {
        return request(APIRoute.updateConnection(form: updatingForm))
    }
}
