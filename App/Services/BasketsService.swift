//
//  BasketsService.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 14/01/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class BasketsService : Service, BasketsServiceProtocol {
    func show(by id: Int) -> Promise<Basket> {
        return request(APIRoute.showBasket(id: id))
    }
    
    func index(for userId: Int) -> Promise<[Basket]> {
        return requestCollection(APIRoute.indexBaskets(userId: userId))
    }
}
