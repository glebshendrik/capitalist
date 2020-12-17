//
//  StatisticsNavigationControllingExtension.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 02/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension StatisticsViewController : TransactionEditViewControllerDelegate, BorrowEditViewControllerDelegate, CreditEditViewControllerDelegate {
    
    var isSelectingTransactionables: Bool {
        return false
    }
    
    func didCreateCredit() {
        loadData()
    }
    
    func didCreateDebt() {
        loadData()
    }
    
    func didCreateLoan() {
        loadData()
    }
    
    func didUpdateCredit() {
        loadData()
    }
    
    func didRemoveCredit() {
        loadData()
    }
    
    func didUpdateDebt() {
        loadData()
    }
    
    func didUpdateLoan() {
        loadData()
    }
    
    func didRemoveDebt() {
        loadData()
    }
    
    func didRemoveLoan() {
        loadData()
    }
    
    func didCreateTransaction(id: Int, type: TransactionType) {
    }
    
    func didUpdateTransaction(id: Int, type: TransactionType) {
        loadData()
    }
    
    func didRemoveTransaction(id: Int, type: TransactionType) {
        loadData()
    }
    
    func shouldShowCreditEditScreen(source: IncomeSourceViewModel?,
                                    destination: TransactionDestination,
                                    creditingTransaction: Transaction?) {
        showCreditEditScreen(source: source, destination: destination, creditingTransaction: creditingTransaction)
    }

    func shouldShowBorrowEditScreen(type: BorrowType, source: TransactionSource, destination: TransactionDestination, borrowingTransaction: Transaction?) {
        showBorrowEditScreen(type: type, source: source, destination: destination, borrowingTransaction: borrowingTransaction)
    }
    
    func showBorrowEditScreen(type: BorrowType, source: TransactionSource, destination: TransactionDestination, borrowingTransaction: Transaction?) {
        modal(factory.borrowEditViewController(delegate: self,
                                               type: type,
                                               borrowId: nil,
                                               source: source,
                                               destination: destination,
                                               borrowingTransaction: borrowingTransaction))
    }
    
    func showCreditEditScreen(source: IncomeSourceViewModel?,
                              destination: TransactionDestination,
                              creditingTransaction: Transaction?) {
        modal(factory.creditEditViewController(delegate: self,
                                               creditId: nil,
                                               source: source,
                                               destination: destination,
                                               creditingTransaction: creditingTransaction))
    }
}

extension StatisticsViewController : FiltersSelectionViewControllerDelegate {
    func showFilters() {        
        modal(factory.statisticsFiltersViewController(delegate: self, dateRangeFilter: viewModel.dateRangeFilter, transactionableFilters: viewModel.transactionableFilters))
    }
    
    func didSelect(filters: [TransactionableFilter]) {
        viewModel.set(filters: filters)
        updateUI()
    }
    
    func showSubscription() {
        modal(factory.subscriptionNavigationViewController(requiredPlans: [.premium, .platinum]))
    }
}

extension StatisticsViewController {
    func showEdit(transaction: TransactionViewModel) {
        if let borrowId = transaction.borrowId, let borrowType = transaction.borrowType {
            showBorrowInfoScreen(borrowId: borrowId, borrowType: borrowType)
        }
        else if let creditId = transaction.creditId {
            showCreditInfoScreen(creditId: creditId)
        }
        else {
            showTransactionEditScreen(transactionId: transaction.id, transactionType: transaction.type)
        }
    }
    
    private func showTransactionEditScreen(transactionId: Int, transactionType: TransactionType?) {
        modal(factory.transactionEditViewController(delegate: self, transactionId: transactionId, transactionType: transactionType))
    }
        
    func showBorrowInfoScreen(borrowId: Int, borrowType: BorrowType) {
        modal(factory.borrowInfoViewController(borrowId: borrowId, borrowType: borrowType, borrow: nil))
    }
        
    private func showCreditInfoScreen(creditId: Int) {
        modal(factory.creditInfoViewController(creditId: creditId, credit: nil))
    }
}

extension StatisticsViewController : StatisticsTitleViewDelegate {
    func didTapTitle() {
        modal(factory.datePeriodSelectionViewController(delegate: self,
                                                        dateRangeFilter: viewModel.dateRangeFilter,
                                                        transactionsMinDate: viewModel.oldestTransactionDate,
                                                        transactionsMaxDate: viewModel.newestTransactionDate))
    }
}

extension StatisticsViewController : DatePeriodSelectionViewControllerDelegate {
    func didSelect(period: DateRangeTransactionFilter?) {
        guard let period = period else { return }
        viewModel.updatePeriods(dateRangeFilter: period)
        clearTransactions()
        shouldScrollTop = true
        loadData()
//        viewModel.updatePresentationData()
//        updateUI()
    }
    
}

extension StatisticsViewController : GraphTableViewCellDelegate {
    func didChangeRange() {
        loadTransactions()
//        viewModel.updatePresentationData()
//        updateUI()
    }
    
    func didTapGraphTypeButton() {
//        viewModel.set(filters: [])
        viewModel.updatePresentationData()
        updateUI()
    }
}

extension StatisticsViewController : ClearFiltersTableViewCellDelegate {
    func didTapClearFilters() {
        didSelect(filters: [])
    }
}
