//
//  AccountConnectionsService.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 03/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class AccountConnectionsService : Service, AccountConnectionsServiceProtocol {
    func index(for userId: Int, connectionId: String) -> Promise<[AccountConnection]> {
        return requestCollection(APIRoute.indexAccountConnections(userId: userId, connectionId: connectionId))
    }
    
    func destroy(by accountConnectionId: Int) -> Promise<Void> {
        return request(APIRoute.destroyAccountConnection(id: accountConnectionId))
    }
}
