//
//  IncomeSourceViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation

class IncomeSourceViewModel : TransactionSource {
    
    var type: TransactionableType {
        return .incomeSource
    }
    
    var iconCategory: IconCategory? {
        return nil
    }
    
    var isTransactionSource: Bool {
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
    
    var isDeleted: Bool {
        return incomeSource.deletedAt != nil
    }
    
    var isChild: Bool {
        return incomeSource.isChild
    }
    
    init(incomeSource: IncomeSource) {
        self.incomeSource = incomeSource
    }
    
    func asTransactionFilter() -> IncomeSourceTransactionFilter {
        return IncomeSourceTransactionFilter(incomeSourceViewModel: self)
    }
    
    private func amount(shouldRound: Bool) -> String {
        return incomeSource.gotCentsAtPeriod.moneyCurrencyString(with: currency, shouldRound: shouldRound) ?? ""
    }
}
