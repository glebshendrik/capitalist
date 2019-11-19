//
//  EntityInfoViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 08/11/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftDate

class EntityInfoViewModel {
    private let transactionsViewModel: TransactionsViewModel
    
    public private(set) var isDataLoading: Bool = false
    
    private var sections: [EntityInfoSection] = []
    private var transactionsSections: [EntityInfoTransactionsSection] = []
    
    var numberOfSections: Int {
        return sections.count
    }
    
    init(transactionsViewModel: TransactionsViewModel) {
        self.transactionsViewModel = transactionsViewModel
    }
    
    func section(at index: Int) -> EntityInfoSection? {
        return sections.item(at: index)
    }
    
    func loadData() -> Promise<Void> {
        setDataLoading()
        return  firstly {
                    when(fulfilled: loadEntityFields(), loadTransactions())
                }.ensure {
                    self.isDataLoading = false
                    self.updatePresentationData()
                }
    }
    
    func setDataLoading() {
        isDataLoading = true
        updateSections()
    }
    
    func updatePresentationData() {
        updateEntityInfoFieldsSection()
        updateTransactionsSections()
        updateSections()
    }
    
    private func updateSections() {
        sections = []
                
        if isDataLoading {
            sections.append(EntityInfoTransactionsLoadingSection())
        }
        else if transactionsSections.count > 0 {
            sections.append(EntityInfoTransactionsHeaderSection())
            sections.append(contentsOf: transactionsSections)
        }
    }
}

// Entity Fields
extension EntityInfoViewModel {
    func updateEntityInfoFieldsSection() {
        
    }
    
    func loadEntityFields() -> Promise<Void> {
        return Promise.value(())
    }
}

// Transactions
extension EntityInfoViewModel {
    func loadTransactions() -> Promise<Void> {
        return transactionsViewModel.loadData()
    }
    
    func removeTransaction(transactionViewModel: TransactionViewModel) -> Promise<Void> {
        setDataLoading()
        return transactionsViewModel.removeTransaction(transactionViewModel: transactionViewModel)
    }
    
    func transactionViewModel(at indexPath: IndexPath) -> TransactionViewModel? {
        guard let section = sections.item(at: indexPath.section) as? EntityInfoTransactionsSection else { return nil }
        return section.transactionViewModel(at: indexPath.row)
    }
    
    private func filterTransactions() {
        transactionsViewModel
            .filterTransactions(sourceOrDestinationFilters: [],
                                       dateRangeFilter: nil)
    }
    
    private func updateTransactionsSections() {
        let groups = transactionsViewModel.filteredTransactionViewModels.groupByKey { $0.gotAt.dateAtStartOf(.day) }
        transactionsSections = groups
            .map { EntityInfoTransactionsSection(date: $0.key, transactionViewModels: $0.value) }
            .sorted(by: { $0.date > $1.date })
    }
}
