//
//  StatisticsViewSection.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 27/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation

protocol StatisticsViewSection {
    var isSectionHeaderVisible: Bool { get }
    var numberOfRows: Int { get }
    var title: String? { get }
}

class SourceOrDestinationFilterEditSection : StatisticsViewSection {
    var isSectionHeaderVisible: Bool { return false }
    var numberOfRows: Int { return 1 }
    var title: String? { return nil }
}

class HistoryTransactionsLoadingSection : StatisticsViewSection {
    var isSectionHeaderVisible: Bool { return false }
    var numberOfRows: Int { return 1 }
    var title: String? { return nil }
}

class HistoryTransactionsHeaderSection : StatisticsViewSection {
    var isSectionHeaderVisible: Bool { return true }
    var numberOfRows: Int { return 1 }
    var title: String? { return nil }
}
