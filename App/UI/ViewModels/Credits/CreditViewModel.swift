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
    
    var returnAmount: String {
        return returnAmount(shouldRound: true)
    }
    
    var paidAmount: String {
        return paidAmount(shouldRound: true)
    }
    
    var returnAmountFormatted: String {
        return "Всего \(returnAmount)"
    }
    
    var paymentsProgress: Float {
        let ratio = Float(credit.paidAmountCents) / Float(credit.returnAmountCents)
        return ratio > 1.0 ? 1.0 : ratio
    }
    
    var currency: Currency {
        return credit.currency
    }
    
    init(credit: Credit) {
        self.credit = credit
    }
    
    private func returnAmount(shouldRound: Bool) -> String {
        return credit.returnAmountCents.moneyCurrencyString(with: currency, shouldRound: shouldRound) ?? ""
    }
    
    private func paidAmount(shouldRound: Bool) -> String {
        return credit.paidAmountCents.moneyCurrencyString(with: currency, shouldRound: shouldRound) ?? ""
    }
}
