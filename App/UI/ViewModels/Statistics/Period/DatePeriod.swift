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
    case quarter
    case month
    case week
    case custom
        
    static var all: [DatePeriod] {
        return [.entire, .year, .quarter, .month, .week, .custom]
    }
    
    var title: String {
        switch self {
        case .entire:
            return NSLocalizedString("Весь период", comment: "Весь период")
        case .year:
            return NSLocalizedString("Год", comment: "Год")
        case .quarter:
            return NSLocalizedString("Квартал", comment: "Квартал")
        case .month:
            return NSLocalizedString("Месяц", comment: "Месяц")
        case .week:
            return NSLocalizedString("Неделя", comment: "Неделя")
        case .custom:
            return NSLocalizedString("Свой период", comment: "Свой период")
        }
    }
    
    var dateFormat: String {
        switch self {
        case .week, .entire, .quarter, .custom:
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
        case .quarter:
            return .quarter
        case .year:
            return .year
        default:
            return nil
        }
    }
    
    var addingUnit: Calendar.Component? {
        return asUnit
    }
    
    var addingComponents: DateComponents? {
        switch self {
        case .week:
            return addingValue.weeks
        case .month:
            return addingValue.months
        case .quarter:
            return addingValue.months
        case .year:
            return addingValue.years
        default:
            return nil
        }
    }
    
    var addingValue: Int {
        switch self {
        case .quarter:
            return 3
        default:
            return 1
        }
    }
    
    func formatPeriod(from: Date?, to: Date?) -> String {
        guard   let from = from,
                let to = to else { return "" }
        
        let fromFormatted = from.string(withFormat: dateFormat)
        let toFormatted = to.string(withFormat: dateFormat)
        
        switch self {
        case .entire, .custom, .week, .quarter:
            return "\(fromFormatted)–\(toFormatted)"
        case .year, .month:
            return fromFormatted
        }
    }
    
    static func fromAccountingPeriod(_ accountingPeriod: AccountingPeriod?) -> DatePeriod? {
        guard let accountingPeriod = accountingPeriod else { return nil }
        
        switch accountingPeriod {
        case .week:
            return .week
        case .month:
            return .month
        case .quarter:
            return .quarter
        case .year:
            return .year
        }
    }
}
