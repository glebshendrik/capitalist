//
//  CurrenciesService.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 10/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class CurrenciesService : Service, CurrenciesServiceProtocol {
    func index() -> Promise<[Currency]> {
        return requestCollection(APIResource.indexCurrencies)
    }
}
