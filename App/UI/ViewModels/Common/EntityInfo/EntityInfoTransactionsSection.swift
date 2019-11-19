//
//  EntityInfoTransactionsSection.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 08/11/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class EntityInfoTransactionsLoadingSection : EntityInfoSection {
    var isSectionHeaderVisible: Bool { return false }
    var numberOfRows: Int { return 1 }
    var title: String? { return nil }
    var type: EntityInfoSectionType { return .transactionsLoader }
}

class EntityInfoTransactionsHeaderSection : EntityInfoSection {
    var isSectionHeaderVisible: Bool { return true }
    var numberOfRows: Int { return 1 }
    var title: String? { return nil }
    var type: EntityInfoSectionType { return .transactionsHeader }
}

class EntityInfoTransactionsSection : EntityInfoSection {
    var isSectionHeaderVisible: Bool { return true }
    var numberOfRows: Int { return transactionViewModels.count }
    var title: String? { return date.dateString(ofStyle: .full) }
    var type: EntityInfoSectionType { return .transactions }
    
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
