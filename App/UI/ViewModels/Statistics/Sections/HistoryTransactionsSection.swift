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
    var title: String? { return date.dateString(ofStyle: .full) }
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
