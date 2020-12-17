//
//  SaltEdgeCustomersService.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 07.12.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class SaltEdgeCustomersService : Service, SaltEdgeCustomersServiceProtocol {
    func createSaltEdgeCustomer(userId: Int) -> Promise<SaltEdgeCustomer> {
        return request(APIRoute.createCustomer(userId: userId))
    }
}
