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
    private let creditsCoordinator: CreditsCoordinatorProtocol
    private let borrowsCoordinator: BorrowsCoordinatorProtocol
    let accountCoordinator: AccountCoordinatorProtocol
    
    var isUpdatingData: Bool = false
    public private(set) var isDeleted: Bool = false
    var hasMoreData: Bool = true
    var needToSaveData: Bool = false
    var transactionToDelete: TransactionViewModel? = nil
    var transactionToDuplicate: TransactionViewModel? = nil
    var defaultPeriod: AccountingPeriod = .month
    
    var transactionable: Transactionable? { return nil }

    var transactionViewModels: [TransactionViewModel] = []
    var transactionsBatchSize: Int = 100
    
    private var sections: [EntityInfoSection] = []
    private var transactionsSections: [EntityInfoTransactionsSection] = []
        
    var title: String? {
        return transactionable?.name
    }
    
    var numberOfSections: Int {
        return sections.count
    }
    
    var lastTransaction: TransactionViewModel? {
        return transactionViewModels.last
    }
    
    var defaultPeriodTitle: String {
        return defaultPeriod.title.lowercased()
    }
    
    init(transactionsCoordinator: TransactionsCoordinatorProtocol,
         creditsCoordinator: CreditsCoordinatorProtocol,
         borrowsCoordinator: BorrowsCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol) {
        self.transactionsCoordinator = transactionsCoordinator
        self.creditsCoordinator = creditsCoordinator
        self.borrowsCoordinator = borrowsCoordinator
        self.accountCoordinator = accountCoordinator
    }
    
    func section(at index: Int) -> EntityInfoSection? {
        return sections[safe: index]
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
        guard !isDeleted else { return Promise.value(()) }
        isUpdatingData = true
        if needToSaveData {
            return saveAndLoadData()
        }
        if let transactionToDelete = transactionToDelete {
            return removeTransaction(transactionViewModel: transactionToDelete)
        }
        if let transactionToDuplicate = transactionToDuplicate {
            return duplicateTransaction(transactionViewModel: transactionToDuplicate)
        }
        return loadData()
    }
    
    private func loadData() -> Promise<Void> {
        return  firstly {
                    when(fulfilled: loadDefaultPeriod(), loadEntity(), loadTransactions())
                }.ensure {
                    self.isUpdatingData = false
                    self.updatePresentationData()
                }
    }
    
    private func loadDefaultPeriod() -> Promise<Void> {
        return  firstly {
                    accountCoordinator.loadCurrentUser()
                }.done { user in
                    self.defaultPeriod = user.defaultPeriod
                }
    }
    
    private func saveAndLoadData() -> Promise<Void> {
        return  firstly {
                    saveEntity()
                }.get {
                    self.postFinantialDataUpdated()
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
    
    func asFilter() -> TransactionableFilter? {
        guard let id = transactionable?.id, let title = transactionable?.name, let type = transactionable?.type else { return nil }
        return TransactionableFilter(id: id, title: title, type: type, iconURL: transactionable?.iconURL, iconPlaceholder: type.defaultIconName)
    }
    
    private func postFinantialDataUpdated() {
        NotificationCenter.default.post(name: MainViewController.finantialDataInvalidatedNotification, object: nil)
    }
    
    func setAsDeleted() {
        isDeleted = true
        postFinantialDataUpdated()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// Transactions
extension EntityInfoViewModel {
    private func loadTransactions() -> Promise<Void> {
        return  firstly {
                    loadTransactionsBatch(lastGotAt: nil)
                }.done { transactions in
                    self.transactionViewModels = transactions.map { TransactionViewModel(transaction: $0) }
                    self.hasMoreData = transactions.count > 0
                    self.updateTransactionsSections()
                }.asVoid()
    }
    
    func loadMoreTransactions() -> Promise<Void> {
        guard !isDeleted else { return Promise.value(()) }
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
        func destroy() -> Promise<Void> {
            if let creditId = transactionViewModel.creditId {
                return creditsCoordinator.destroyCredit(by: creditId, deleteTransactions: true)
            }
            if let borrowId = transactionViewModel.borrowId, transactionViewModel.isBorrowing {
                return transactionViewModel.isDebt
                    ? borrowsCoordinator.destroyDebt(by: borrowId, deleteTransactions: true)
                    : borrowsCoordinator.destroyLoan(by: borrowId, deleteTransactions: true)
            }
            return transactionsCoordinator.destroy(by: transactionViewModel.id)
        }
        return  firstly {
                    destroy()
                }.get {
                    self.postFinantialDataUpdated()
                }.then {
                    self.loadData()
                }.done {
                    self.transactionToDelete = nil
                }
    }
    
    private func duplicateTransaction(transactionViewModel: TransactionViewModel) -> Promise<Void> {
        return  firstly {
                    transactionsCoordinator.duplicate(by: transactionViewModel.id)
                }.get {
                    self.postFinantialDataUpdated()
                }.then {
                    self.loadData()
                }.done {
                    self.transactionToDuplicate = nil
                }
    }
    
    func transactionViewModel(at indexPath: IndexPath) -> TransactionViewModel? {        
        guard let section = sections[safe: indexPath.section] as? EntityInfoTransactionsSection else { return nil }
        return section.transactionViewModel(at: indexPath.row)
    }
    
    func indexPath(for transactionViewModel: TransactionViewModel?) -> IndexPath? {
        guard   let transactionViewModel = transactionViewModel,
                let section = transactionsSections.last(where: {  $0.date == transactionViewModel.gotAtStartOfDay }),
                let sectionIndex = sections.lastIndex(where: { $0.id == section.id }),
                let rowIndex = section.index(of: transactionViewModel) else { return nil }
        return IndexPath(row: rowIndex, section: sectionIndex)
    }
    
    private func updateTransactionsSections() {
        let groups = transactionViewModels.groupByKey { $0.gotAtStartOfDay }
        transactionsSections = groups
            .map { EntityInfoTransactionsSection(date: $0.key, transactionViewModels: $0.value) }
            .sorted(by: { $0.date > $1.date })
    }
}
