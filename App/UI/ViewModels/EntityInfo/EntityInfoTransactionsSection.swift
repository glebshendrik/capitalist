//
//  EntityInfoTransactionsSection.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 08/11/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class EntityInfoTransactionsLoadingSection : EntityInfoSection {
    var id: String {
        return type.rawValue
    }
    
    var isSectionHeaderVisible: Bool { return false }
    var numberOfRows: Int { return 1 }
    var title: String? { return nil }
    var type: EntityInfoSectionType { return .transactionsLoader }
}

class EntityInfoTransactionsHeaderSection : EntityInfoSection {
    var id: String {
        return type.rawValue
    }
    var isSectionHeaderVisible: Bool { return true }
    var numberOfRows: Int { return 1 }
    var title: String? { return nil }
    var type: EntityInfoSectionType { return .transactionsHeader }
}

class EntityInfoTransactionsSection : EntityInfoSection {
    var id: String {
        return type.rawValue + date.toISO()
    }
    var isSectionHeaderVisible: Bool { return true }
    var numberOfRows: Int { return transactionViewModels.count }    
    var title: String? { return date.string(withFormat: "dd.MM.yyyy") }
    var type: EntityInfoSectionType { return .transactions }
    
    let date: Date
    private let transactionViewModels: [TransactionViewModel]
    
    init(date: Date,
         transactionViewModels: [TransactionViewModel]) {
        self.date = date
        self.transactionViewModels = transactionViewModels
    }
    
    func transactionViewModel(at index: Int) -> TransactionViewModel? {        
        return transactionViewModels[safe: index]
    }
    
    func index(of transactionViewModel: TransactionViewModel) -> Int? {
        return transactionViewModels.lastIndex { $0.id == transactionViewModel.id }
    }
}
