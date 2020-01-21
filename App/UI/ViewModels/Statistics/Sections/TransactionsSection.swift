//
//  TransactionsSection.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 16/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class TransactionsSection : StatisticsViewSection {
    var isSectionHeaderVisible: Bool { return true }
    var numberOfRows: Int { return transactionViewModels.count }
    var title: String? { return date.string(withFormat: "dd.MM.yyyy") }
    var type: StatisticsViewSectionType { return .transactions }
    
    let date: Date
    private let transactionViewModels: [TransactionViewModel]
    
    init(date: Date,
         transactionViewModels: [TransactionViewModel]) {
        self.date = date
        self.transactionViewModels = transactionViewModels
    }
    
    func transactionViewModel(at index: Int) -> TransactionViewModel? {
        return transactionViewModels.item(at: index)
    }
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
