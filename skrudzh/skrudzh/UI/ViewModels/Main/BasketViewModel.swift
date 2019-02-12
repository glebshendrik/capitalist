//
//  BasketViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 15/01/2019.
//  Copyright © 2019 rubikon. All rights reserved.
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
    
    var monthlySpentCents: Int {
        return basket.monthlySpentCents
    }
    
    var currency: Currency {
        return basket.currency
    }
    
    var monthlySpent: String? {
        return monthlySpentCents.moneyCurrencyString(with: currency)
    }
    
    var selected: Bool = false
    
    init(basket: Basket) {
        self.basket = basket
    }
    
    func append(cents: Int) {        
        basket.monthlySpentCents += cents
    }
    
    func select() {
        selected = true
    }
    
    func unselect() {
        selected = false
    }
}
