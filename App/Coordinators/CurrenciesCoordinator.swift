//
//  CurrenciesCoordinator.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class CurrenciesCoordinator : CurrenciesCoordinatorProtocol {
    private let currenciesService: CurrenciesServiceProtocol
    
    init(currenciesService: CurrenciesServiceProtocol) {
        self.currenciesService = currenciesService
    }
    
    func index() -> Promise<[Currency]> {
        return currenciesService.index()
    }
}
