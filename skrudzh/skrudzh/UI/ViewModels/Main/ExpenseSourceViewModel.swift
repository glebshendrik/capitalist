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
        return expenseSource.amountCents.moneyStringWithCurrency(symbol: "₽") ?? "0 ₽"
    }
    
    var iconURL: URL? {
        return expenseSource.iconURL
    }
    
    var isGoal: Bool {
        return expenseSource.isGoal
    }
    
    var goalProgress: Double {
        guard isGoal, let goalAmountCents = expenseSource.goalAmountCents else { return 0 }
        let progress = Double(expenseSource.amountCents) / Double(goalAmountCents)
        return progress > 1.0 ? 1.0 : progress
    }
    
    var isGoalCompleted: Bool {
        return goalProgress == 1.0
    }
    
    init(expenseSource: ExpenseSource) {
        self.expenseSource = expenseSource
    }
}
