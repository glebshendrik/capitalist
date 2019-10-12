//
//  ActivesService.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class ActivesService : Service, ActivesServiceProtocol {
    func indexActives(for basketId: Int) -> Promise<[Active]> {
        return requestCollection(APIRoute.indexActives(basketId: basketId))
    }
    
    func index(for userId: Int) -> Promise<[Active]> {
        return requestCollection(APIRoute.indexUserActives(userId: userId))
    }
    
    func createActive(with creationForm: ActiveCreationForm) -> Promise<Active> {
        return request(APIRoute.createActive(form: creationForm))
    }
        
    func showActive(by id: Int) -> Promise<Active> {
        return request(APIRoute.showActive(id: id))
    }
    
    func updateActive(with updatingForm: ActiveUpdatingForm) -> Promise<Void> {
        return request(APIRoute.updateActive(form: updatingForm))
    }
    
    func updatePosition(with updatingForm: ActivePositionUpdatingForm) -> Promise<Void> {
        return request(APIRoute.updateActivePosition(form: updatingForm))
    }
    
    func destroyActive(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return request(APIRoute.destroyActive(id: id, deleteTransactions: deleteTransactions))
    }
}
