//
//  CurrenciesCoordinator.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 10/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
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
