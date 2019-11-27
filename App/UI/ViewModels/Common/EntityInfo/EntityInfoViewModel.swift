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
    private let transactionsCoordinator: TransactionsCoordinatorProtocol
    
    public var needToSaveData: Bool = false
    public var transactionToDelete: TransactionViewModel? = nil
            
    var transactionable: Transactionable? { return nil }

    var transactionViewModels: [TransactionViewModel] = []
    var transactionsBatchSize: Int = 10
    
    private var sections: [EntityInfoSection] = []
    private var transactionsSections: [EntityInfoTransactionsSection] = []
    
    var hasMoreData: Bool = true
    
    var title: String? {
        return transactionable?.name
    }
    
    var numberOfSections: Int {
        return sections.count
    }
    
    var lastTransaction: TransactionViewModel? {
        return transactionViewModels.last
    }
    
    init(transactionsCoordinator: TransactionsCoordinatorProtocol) {
        self.transactionsCoordinator = transactionsCoordinator
    }
    
    func section(at index: Int) -> EntityInfoSection? {
        return sections.item(at: index)
    }
    
    
    
    func updatePresentationData() {
        updateTransactionsSections()
        updateSections()
    }
    
    private func updateSections() {
        let fieldsSection = EntityInfoFieldsSection(infoFields: entityInfoFields())

        sections = [fieldsSection, EntityInfoTransactionsHeaderSection()]
                    
        if transactionsSections.count > 0 {
            sections.append(contentsOf: transactionsSections)
        }
    }
    
    func updateData() -> Promise<Void> {
        if needToSaveData {
            return saveAndLoadData()
        }
        if let transactionToDelete = transactionToDelete {
            return removeTransaction(transactionViewModel: transactionToDelete)
        }
        return loadData()
    }
    
    private func loadData() -> Promise<Void> {
        return  firstly {
                    when(fulfilled: loadEntity(), loadTransactions())
                }.ensure {
                    self.updatePresentationData()
                }
    }
    
    private func saveAndLoadData() -> Promise<Void> {
        return  firstly {
                    saveEntity()
                }.then {
                    self.loadData()
                }.done {
                    self.needToSaveData = false
                }
    }
    
    func saveEntity() -> Promise<Void> {
        return Promise.value(())
    }
    
    func loadEntity() -> Promise<Void> {
        return Promise.value(())
    }
    
    func entityInfoFields() -> [EntityInfoField] {
        return []
    }
    
    func loadTransactionsBatch(lastGotAt: Date?) -> Promise<[Transaction]> {
        return transactionsCoordinator.index(transactionableId: transactionable?.id,
                                             transactionableType: transactionable?.type,
                                             creditId: nil,
                                             borrowId: nil,
                                             borrowType: nil,
                                             count: transactionsBatchSize,
                                             lastGotAt: lastGotAt)
    }
    
    func asFilter() -> SourceOrDestinationTransactionFilter? {
        guard let id = transactionable?.id, let title = transactionable?.name, let type = transactionable?.type else { return nil }
        return SourceOrDestinationTransactionFilter(id: id, title: title, type: type)
    }
}

// Transactions
extension EntityInfoViewModel {
    func loadTransactions() -> Promise<Void> {
        return  firstly {
                    loadTransactionsBatch(lastGotAt: nil)
                }.done { transactions in
                    self.transactionViewModels = transactions.map { TransactionViewModel(transaction: $0) }
                    self.hasMoreData = transactions.count > 0
                    self.updateTransactionsSections()
                }.asVoid()
    }
    
    func loadMoreTransactions() -> Promise<Void> {
        return  firstly {
                    loadTransactionsBatch(lastGotAt: transactionViewModels.last?.gotAt)
                }.done { transactions in
                    let batch = transactions.map { TransactionViewModel(transaction: $0) }
                    self.transactionViewModels.append(contentsOf: batch)
                    self.hasMoreData = transactions.count > 0
                    self.updatePresentationData()
                }.asVoid()
    }
    
    private func removeTransaction(transactionViewModel: TransactionViewModel) -> Promise<Void> {
        return  firstly {
                    transactionsCoordinator.destroy(by: transactionViewModel.id)
                }.then {
                    self.loadData()
                }.done {
                    self.transactionToDelete = nil
                }
    }
    
    func transactionViewModel(at indexPath: IndexPath) -> TransactionViewModel? {
        guard let section = sections.item(at: indexPath.section) as? EntityInfoTransactionsSection else { return nil }
        return section.transactionViewModel(at: indexPath.row)
    }
    
    func indexPath(for transactionViewModel: TransactionViewModel?) -> IndexPath? {
        guard   let transactionViewModel = transactionViewModel,
                let section = transactionsSections.last(where: {  $0.date.dateAtStartOf(.day) == transactionViewModel.gotAt.dateAtStartOf(.day) }),
                let sectionIndex = sections.lastIndex(where: { $0.id == section.id }),
                let rowIndex = section.index(of: transactionViewModel) else { return nil }
        return IndexPath(row: rowIndex, section: sectionIndex)
    }
    
    private func updateTransactionsSections() {
        let groups = transactionViewModels.groupByKey { $0.gotAt.dateAtStartOf(.day) }
        transactionsSections = groups
            .map { EntityInfoTransactionsSection(date: $0.key, transactionViewModels: $0.value) }
            .sorted(by: { $0.date > $1.date })
    }
}
