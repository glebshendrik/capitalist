//
//  IncomeSourceViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 13/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation

class IncomeSourceViewModel {
    
    public private(set) var incomeSource: IncomeSource
    
    var id: Int {
        return incomeSource.id
    }
    
    var name: String {
        return incomeSource.name
    }
    
    var incomesAmount: String {
        return 0.moneyCurrencyString(with: incomeSource.currency) ?? ""
    }
    
    init(incomeSource: IncomeSource) {
        self.incomeSource = incomeSource
    }
}
