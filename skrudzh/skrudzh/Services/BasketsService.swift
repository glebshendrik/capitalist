//
//  BasketsService.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 14/01/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class BasketsService : Service, BasketsServiceProtocol {
    func show(by id: Int) -> Promise<Basket> {
        return request(APIResource.showBasket(id: id))
    }
    
    func index(for userId: Int) -> Promise<[Basket]> {
        return requestCollection(APIResource.indexBaskets(userId: userId))
    }
}
