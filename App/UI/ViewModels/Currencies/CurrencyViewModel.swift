//
//  CurrencyViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class CurrencyViewModel {
    public private(set) var currency: Currency
    
    var code: String {
        return currency.code
    }
    
    var name: String {
        return currency.translatedName
    }
    
    var symbol: String {
        return currency.symbol
    }
    
    init(currency: Currency) {
        self.currency = currency
    }
}
