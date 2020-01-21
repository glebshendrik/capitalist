//
//  GraphPeriodScale.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

enum DatePeriod {
    case entire
    case year
    case month
    case week
    case custom
        
    static var all: [DatePeriod] {
        return [.entire, .year, .month, .week, .custom]
    }
    
    var title: String {
        switch self {
        case .entire:
            return "Весь период"
        case .year:
            return "Год"
        case .month:
            return "Месяц"
        case .week:
            return "Неделя"
        case .custom:
            return "Свой период"
        }
    }
    
    var dateFormat: String {
        switch self {
        case .week, .entire, .custom:
            return "dd.MM.yy"
        case .month:
            return "LLLL yyyy"
        case .year:
            return "yyyy"
        }
    }
    
    var asUnit: Calendar.Component? {
        switch self {
        case .week:
            return .weekOfYear
        case .month:
            return .month
        case .year:
            return .year
        default:
            return nil
        }
    }
    
    var addingUnit: Calendar.Component? {
        return asUnit
    }
    
    var addingValue: Int {
        return 1
    }
    
    func formatPeriod(from: Date?, to: Date?) -> String {
        guard   let from = from,
                let to = to else { return "" }
        
        let fromFormatted = from.string(withFormat: dateFormat)
        let toFormatted = to.string(withFormat: dateFormat)
        
        switch self {
        case .entire, .custom, .week:
            return "\(fromFormatted)–\(toFormatted)"
        case .year, .month:
            return fromFormatted
        }
    }
}