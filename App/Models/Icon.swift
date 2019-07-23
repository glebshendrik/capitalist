//
//  Icon.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation

enum IconCategory : String, Codable {
    case expenseSource = "expense_source"
    case expenseSourceGoal = "expense_source_goal"
    case expenseSourceDebt = "expense_source_debt"
    case expenseCategoryJoy = "expense_category_joy"
    case expenseCategoryRisk = "expense_category_risk"
    case expenseCategorySafe = "expense_category_safe"
    
    var defaultIconName: String {
        switch self {
        case .expenseCategoryJoy:
            return ""
        case .expenseCategoryRisk:
            return ""
        case .expenseCategorySafe:
            return ""
        case .expenseSource:
            return ""
        case .expenseSourceGoal:
            return ""
        case .expenseSourceDebt:
            return ""
        }
    }
}

struct Icon : Decodable {
    let id: Int
    let url: URL
    let category: IconCategory
}
