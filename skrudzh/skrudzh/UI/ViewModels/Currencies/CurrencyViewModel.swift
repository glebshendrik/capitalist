//
//  CurrencyViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 10/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation

class CurrencyViewModel {
    public private(set) var currency: Currency
    
    var code: String {
        return currency.code
    }
    
    init(currency: Currency) {
        self.currency = currency
    }
}
