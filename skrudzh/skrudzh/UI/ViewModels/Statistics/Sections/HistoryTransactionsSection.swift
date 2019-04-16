//
//  HistoryTransactionsSection.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 16/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation

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
