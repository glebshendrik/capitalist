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

class GraphSection : StatisticsViewSection {
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

class HistoryTransactionsSection : StatisticsViewSection {
    var isSectionHeaderVisible: Bool { return true }
    var numberOfRows: Int { return historyTransactionViewModels.count }
    var title: String? { return date.dateString(ofStyle: .full) }
    
    let date: Date
    private let historyTransactionViewModels: [HistoryTransactionViewModel]
    
    init(date: Date,
         historyTransactionViewModels: [HistoryTransactionViewModel]) {
        self.date = date
        self.historyTransactionViewModels = historyTransactionViewModels
    }
    
    func historyTransactionViewModel(at index: Int) -> HistoryTransactionViewModel? {
        return historyTransactionViewModels.item(at: index)
    }
}
