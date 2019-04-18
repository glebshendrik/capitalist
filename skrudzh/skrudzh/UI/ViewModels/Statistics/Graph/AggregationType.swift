//
//  AggregationType.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 16/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation

enum AggregationType {
    case percent
    case total
    case average
    case maximum
    case minimum
    
    var title: String {
        switch self {
        case .percent:
            return "Проценты"
        case .total:
            return "Сумма"
        case .average:
            return "Среднее"
        case .maximum:
            return "Максимум"
        case .minimum:
            return "Минимум"
        }
    }
}
