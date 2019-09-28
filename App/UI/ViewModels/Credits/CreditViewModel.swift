//
//  CreditViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class CreditViewModel {
    public private(set) var credit: Credit
    
    var id: Int {
        return credit.id
    }
    
    var iconURL: URL? {
        return credit.iconURL
    }
        
    var name: String {
        return credit.name
    }
    
    var type: CreditType {
        return credit.creditType
    }
    
    var typeName: String {
        return type.localizedName
    }
    
    var amount: String {
        return amount(shouldRound: true)
    }
    
    var paidAmount: String {
        return paidAmount(shouldRound: true)
    }
    
    var paidAmountFormatted: String {
        return "Всего \(paidAmount)"
    }
    
    var paymentsProgress: Float {
        let ratio = Float(credit.paidAmountCents) / Float(credit.amountCents)
        return ratio > 1.0 ? 1.0 : ratio
    }
    
    var currency: Currency {
        return credit.currency
    }
    
    init(credit: Credit) {
        self.credit = credit
    }
    
    private func amount(shouldRound: Bool) -> String {
        return credit.amountCents.moneyCurrencyString(with: currency, shouldRound: shouldRound) ?? ""
    }
    
    private func paidAmount(shouldRound: Bool) -> String {
        return credit.paidAmountCents.moneyCurrencyString(with: currency, shouldRound: shouldRound) ?? ""
    }
}
