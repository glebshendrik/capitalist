//
//  GraphType.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

enum GraphType {
    case all
    case incomes
    case expenses
    
    static var switchList: [GraphType] {
        return [.all, .incomes, .expenses]
    }
    
    var title: String {
        switch self {
        case .all:
            return "Все"
        case .incomes:
            return "Доход"
        case .expenses:
            return "Расходы"
        }
    }
}
