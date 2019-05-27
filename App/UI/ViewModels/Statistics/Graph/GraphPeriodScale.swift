//
//  GraphPeriodScale.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

enum GraphPeriodScale {
    case days
    case weeks
    case months
    case quarters
    case years
    
    static var switchList: [GraphPeriodScale] {
        return [.days, .weeks, .months, .quarters, .years]
    }
    
    var asUnit: Calendar.Component {
        switch self {
        case .days:
            return .day
        case .weeks:
            return .weekOfYear
        case .months:
            return .month
        case .quarters:
            return .quarter
        case .years:
            return .year
        }
    }
    
    var addingUnit: Calendar.Component {
        if case .quarters = self {
            return .month
        }
        return asUnit
    }
    
    var addingValue: Int {
        if case .quarters = self {
            return 3
        }
        return 1
    }
    
    var dateFormat: String {
        switch self {
        case .days,
             .weeks:
            return "dd.MM.yy"
        case .months:
            return "MMM yyyy"
        case .quarters:
            return "Q`yyyy"
        case .years:
            return "yyyy"
        }
    }
    
    var title: String {
        switch self {
        case .days:
            return "Дни"
        case .weeks:
            return "Недели"
        case .months:
            return "Месяцы"
        case .quarters:
            return "Кварталы"
        case .years:
            return "Годы"
        }
    }
}
