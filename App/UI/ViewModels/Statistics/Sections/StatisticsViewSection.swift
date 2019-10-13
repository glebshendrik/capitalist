//
//  StatisticsViewSection.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 27/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

enum StatisticsViewSectionType {
    case filterEdit
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

class SourceOrDestinationFilterEditSection : StatisticsViewSection {
    var isSectionHeaderVisible: Bool { return false }
    var numberOfRows: Int { return 1 }
    var title: String? { return nil }
    var type: StatisticsViewSectionType { return .filterEdit }
}

class TransactionsLoadingSection : StatisticsViewSection {
    var isSectionHeaderVisible: Bool { return false }
    var numberOfRows: Int { return 1 }
    var title: String? { return nil }
    var type: StatisticsViewSectionType { return .transactionsLoader }
}

class TransactionsHeaderSection : StatisticsViewSection {
    var isSectionHeaderVisible: Bool { return true }
    var numberOfRows: Int { return 1 }
    var title: String? { return nil }
    var type: StatisticsViewSectionType { return .transactionsHeader }
}
