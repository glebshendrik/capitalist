//
//  Icon.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 28/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation

enum IconCategory : String, Codable {
    case expenseSource = "expense_source"
    case common = "common"
    
    var defaultIconName: String {
        switch self {
        case .expenseSource:
            return "expense-source-default-icon"
        case .common:
            return "income-source-default-icon"
        }
    }
}

struct Icon : Decodable {
    let id: Int
    let url: URL
    let category: IconCategory
}
