//
//  ExpenseSourceViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 25/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation

class ExpenseSourceViewModel {
    
    public private(set) var expenseSource: ExpenseSource
    
    var id: Int {
        return expenseSource.id
    }
    
    var name: String {
        return expenseSource.name
    }
    
    var amount: String {
        return expenseSource.amount
    }
    
    var iconURL: URL? {
        return expenseSource.iconURL
    }
    
    init(expenseSource: ExpenseSource) {
        self.expenseSource = expenseSource
    }
}
