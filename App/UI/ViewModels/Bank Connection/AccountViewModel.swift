//
//  AccountViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 04/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import SaltEdge
import SwiftDate

class AccountViewModel {
    let account: Account
    
    var id: Int {
        return account.id
    }
    
    var accountId: String {
        return account.accountId
    }
    
    var name: String {
        return account.accountFullName ?? account.accountName
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
    
    var amountDecimal: String? {
        return amountCents?.moneyDecimalString(with: currency)
    }
    
    var balance: String {
        return amount ?? "\(account.balance) \(currencyCode)"
    }
    
    var nature: AccountNature {        
        return account.nature
    }
    
    var creditLimitCents: Int? {
        return account.creditLimit
//        guard let creditLimit = account.extra?.creditLimit else { return nil }
//        return "\(creditLimit)".intMoney(with: currency)
    }
    
    var creditLimit: String? {
        return creditLimitCents?.moneyCurrencyString(with: currency, shouldRound: false)
    }
    
    var creditLimitDecimal: String? {
        return creditLimitCents?.moneyDecimalString(with: currency)
    }
    
    var cards: String? {
        return account.cardNumbers?.joined(separator: ", ")
    }
    
    var cardLastNumbers: String? {
        guard let numbers = account.cardNumbers?.first?.components(separatedBy: "*").last else { return nil }
        return "•••• \(numbers)"
    }
    
    var cardType: CardType? {
        return account.cardType
    }
    
    init(account: Account) {
        self.account = account
    }
}
