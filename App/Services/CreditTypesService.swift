//
//  CreditTypesService.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class CreditTypesService : Service, CreditTypesServiceProtocol {
    func indexCreditTypes() -> Promise<[CreditType]> {
        return requestCollection(APIRoute.indexCreditTypes)
    }
}
