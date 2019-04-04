//
//  IncomeSourceViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 13/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation

class IncomeSourceViewModel : TransactionStartable {
    
    var canStartTransaction: Bool {
        return true
    }
    
    public private(set) var incomeSource: IncomeSource
    
    var id: Int {
        return incomeSource.id
    }
    
    var name: String {
        return incomeSource.name
    }
    
    var amountRounded: String {
        return amount(shouldRound: true)
    }
    
    var amount: String {
        return amount(shouldRound: false)
    }
    
    var currency: Currency {
        return incomeSource.currency
    }
    
    var iconURL: URL? {
        return nil
    }
    
    init(incomeSource: IncomeSource) {
        self.incomeSource = incomeSource
    }
    
    private func amount(shouldRound: Bool) -> String {
        return incomeSource.monthlyGotCents.moneyCurrencyString(with: currency, shouldRound: shouldRound) ?? ""
    }
}
