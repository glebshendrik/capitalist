//
//  AccountViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 04/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import SaltEdge

class AccountViewModel {
    let account: SEAccount
    let currency: Currency
    
    var id: String {
        return account.id
    }
    
    var name: String {
        return account.name
    }
    
    var currencyCode: String {
        return account.currencyCode
    }
    
    var amountCents: Int? {
        return "\(account.balance)".intMoney(with: currency)
    }
    
    var amount: String? {
        return amountCents?.moneyCurrencyString(with: currency, shouldRound: false)
    }
    
    var balance: String {
        return amount ?? "\(account.balance) \(currencyCode)"
    }
    
    var nature: AccountNature {        
        return AccountNature.init(rawValue: account.nature) ?? .account
    }
    
    var connectionId: String {
        return account.connectionId
    }
    
    var creditLimitCents: Int? {
        guard let creditLimit = account.extra?.creditLimit else { return nil }
        return "\(creditLimit)".intMoney(with: currency)        
    }
    
    var cards: String? {
        return account.extra?.cards?.joined(separator: ", ")
    }
    
    init(account: SEAccount, currency: Currency) {
        self.account = account
        self.currency = currency
    }
}
