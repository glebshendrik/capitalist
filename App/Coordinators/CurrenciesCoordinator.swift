//
//  CurrenciesCoordinator.swift
//  Capitalist
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
    
    func hash() -> Promise<[String : Currency]> {
        return  firstly {
                    index()
                }.then { currencies -> Promise<[String : Currency]> in
                    let hash = currencies.reduce(into: [String : Currency]()) { (hash, item) in
                        hash[item.code] = item
                    }
                    return Promise.value(hash)
                }
    }
}
