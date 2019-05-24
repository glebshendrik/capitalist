//
//  CurrenciesViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class CurrenciesViewModel {
    private let currenciesCoordinator: CurrenciesCoordinatorProtocol
    
    private var currencyViewModels: [CurrencyViewModel] = []
    
    var numberOfCurrencies: Int {
        return currencyViewModels.count
    }
    
    init(currenciesCoordinator: CurrenciesCoordinatorProtocol) {
        self.currenciesCoordinator = currenciesCoordinator
    }
    
    func loadCurrencies() -> Promise<Void> {
        return  firstly {
                    currenciesCoordinator.index()
                }.done { currencies in
                    self.currencyViewModels = currencies.map { CurrencyViewModel(currency: $0) }                
                }
    }
    
    func currencyViewModel(at indexPath: IndexPath) -> CurrencyViewModel? {
        return currencyViewModels.item(at: indexPath.row)
    }
}
