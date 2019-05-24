//
//  GraphType.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

enum GraphType {
    case income
    case incomePie
    case expenses
    case expensesPie
    case incomeAndExpenses
    case cashFlow
    case netWorth
    
    static var switchList: [GraphType] {
        return [.income, .expenses, .incomeAndExpenses, .cashFlow, .netWorth]
    }
    
    var title: String {
        switch self {
        case .income:
            return "Доход"
        case .incomePie:
            return "Доход"
        case .expenses:
            return "Расходы"
        case .expensesPie:
            return "Расходы"
        case .incomeAndExpenses:
            return "Доход и Расходы"
        case .cashFlow:
            return "Кошельки"
        case .netWorth:
            return "Накопления"
        }
    }
}
