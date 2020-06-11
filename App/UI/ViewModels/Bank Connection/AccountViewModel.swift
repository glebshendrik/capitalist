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
    let account: Account
    
    var id: Int {
        return account.id
    }
    
    var accountId: String {
        return account.accountId
    }
    
    var name: String {
        return account.accountName
    }
    
    var currency: Currency {
        return account.currency
    }
    
    var currencyCode: String {
        return account.currency.code
    }
    
    var amountCents: Int? {
        return account.balance
//        return "\(account.balance)".intMoney(with: currency)
    }
    
    var amount: String? {
        return amountCents?.moneyCurrencyString(with: currency, shouldRound: false)
    }
    
    var balance: String {
        return amount ?? "\(account.balance) \(currencyCode)"
    }
    
    var nature: AccountNature {        
        return account.nature
    }
    
    var connectionId: String {
        return account.connection.saltedgeId
    }
    
    var creditLimitCents: Int? {
        return account.creditLimit
//        guard let creditLimit = account.extra?.creditLimit else { return nil }
//        return "\(creditLimit)".intMoney(with: currency)
    }
    
    var creditLimit: String? {
        return creditLimitCents?.moneyCurrencyString(with: currency, shouldRound: false)
    }
    
    var cards: String? {
        return account.cardNumbers?.joined(separator: ", ")
    }
    
    var providerLogoURL: URL? {
        return account.connection.providerLogoURL
    }
    
    var cardLastNumbers: String? {
        return account.cardNumbers?.first
    }
    
    var cardType: CardType? {
        return account.cardType
    }
    
    init(account: Account) {
        self.account = account
    }
}
