//
//  BasketViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 15/01/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class BasketViewModel {
    
    public private(set) var basket: Basket
    
    var id: Int {
        return basket.id
    }
    
    var basketType: BasketType {
        return basket.basketType
    }
    
    var spentCents: Int {
        return basket.spentCentsAtPeriod
    }
    
    var currency: Currency {
        return basket.currency
    }
    
    var spent: String? {
        return spentCents.moneyCurrencyString(with: currency, shouldRound: true)
    }
    
    init(basket: Basket) {
        self.basket = basket
    }    
}
