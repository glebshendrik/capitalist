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
    
    var currency: Currency {
        return incomeSource.currency
    }
    
    var incomesAmount: String {
        return 0.moneyCurrencyString(with: currency) ?? ""
    }
    
    var iconURL: URL? {
        return nil
    }
    
    var amount: String {
        return incomesAmount
    }
    
    init(incomeSource: IncomeSource) {
        self.incomeSource = incomeSource
    }
}
