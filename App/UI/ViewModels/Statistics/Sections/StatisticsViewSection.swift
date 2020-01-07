//
//  StatisticsViewSection.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 27/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

enum StatisticsViewSectionType {
    case graph
    case graphFilters
    case transactionsLoader
    case transactionsHeader
    case transactions
}

protocol StatisticsViewSection {
    var isSectionHeaderVisible: Bool { get }
    var numberOfRows: Int { get }
    var title: String? { get }
    var type: StatisticsViewSectionType { get }
}
